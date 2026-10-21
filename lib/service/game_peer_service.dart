import 'dart:async';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:peer_rtc/peer_rtc.dart';
import 'dart:developer';

class GamePeerService {
  final Peer peer;
  late StarHub starHub;

  bool isPeerConnected = false;
  String myPeerId;

  /// Disponibilidade do host vista pelo cliente.
  /// NÃO derivamos de starHub.table: em cliente, o host morto permanece
  /// na tabela com status `connected`. Rastreamos por evento.
  bool _hostAvailable = false;

  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onData => _dataController.stream;

  final _peerLeftController = StreamController<String>.broadcast();
  Stream<String> get onPeerLeft => _peerLeftController.stream;

  final _newHostController = StreamController<String>.broadcast();
  Stream<String> get onNewHost => _newHostController.stream;

  final _hostAbruptLoss = StreamController<String>.broadcast();
  Stream<String> get onHostAbruptLoss => _hostAbruptLoss.stream;

  bool _destroyed = false;

  static const hostReceivedMessage = "[HOST] Dados recebidos do StarHub do peer";
  static const clientReceivedMessage = "[CLIENT] Dados recebidos do StarHub do peer";

  GamePeerService({required this.peer, required this.myPeerId}) {
    starHub = StarHub(peer: peer);
    _initListeners();
  }

  bool get isHost => starHub.isHost;

  /// O que o cliente consulta antes de enviar.
  bool get isHostAvailable => isHost || _hostAvailable;

  /// Guard único contra callback tardio escrevendo em controller fechado.
  void _emit<T>(StreamController<T> c, T value) {
    if (_destroyed || c.isClosed) return;
    c.add(value);
  }

  void _initListeners() {
    // Sinal de queda/CONTUDO abrupta do host, no cliente.
    starHub.onHostDisconnected.listen((hostId) {
      _hostAvailable = false;
      _emit(_hostAbruptLoss, hostId);
    });

    starHub.onHostChanged.listen((newHostId) {
      log("Aviso do StarHub - Host atualizado na rede: $newHostId");
      _hostAvailable = true;
      _emit(_newHostController, newHostId);
    });

    starHub.onPeerConnected.listen((peerId) {
      if (peerId == starHub.hostPeerId) _hostAvailable = true;
    });

    starHub.onPeerDisconnected.listen((peerId) {
      if (peerId == starHub.hostPeerId) _hostAvailable = false;
    });

    starHub.onData.listen((incomingData) {
      if (_destroyed) return;
      final emitterPeerId = incomingData['from'];
      if (emitterPeerId == myPeerId) return;
      if (isHost) {
        log("$hostReceivedMessage $emitterPeerId");
      } else {
        log("$clientReceivedMessage $emitterPeerId");
      }
      _emit(_dataController, incomingData);
    });

    starHub.onPeerLeft.listen((entry) {
      log("Peer desconectado da rede StarHub: ${entry.peerId}");
      _emit(_peerLeftController, entry.peerId);
    });

    starHub.onPeerJoined.listen((entry) {
      log("Novo peer conectado ao StarHub Host: ${entry.peerId}");
    });
  }

  Future<void> startAsHost() async {
    await starHub.create();
    log("[HOST] Criação do StarHub como Host concluída.");
    isPeerConnected = true;
  }

  Future<void> _joinAsClient(String hostPeerId, Player localPlayer) async {
    try {
      final hostReady = starHub.onPeerConnected.firstWhere((connectedPeerId) => connectedPeerId == hostPeerId);
      await starHub.join(hostPeerId);
      await hostReady.timeout(const Duration(seconds: 5));
      isPeerConnected = true;
      _hostAvailable = true;
      log("[CLIENT] Conectado com sucesso ao StarHub do Host: $hostPeerId");

      send(EventDTO(
        referenceRound: 1,
        type: EventType.joinTable,
        sourcePlayer: localPlayer,
      ));
    } on TimeoutException {
      isPeerConnected = false;
      _hostAvailable = false;
      log("[CLIENT] Timeout ao tentar conexão com o host candidate: $hostPeerId");
    } catch (e) {
      isPeerConnected = false;
      _hostAvailable = false;
      log("[CLIENT] Erro ao entrar no StarHub do Host: $e");
    }
  }

  Future<void> connectToHost({required Player player, String? destinationPeerId, List<String>? canditadesPeersId}) async {
    try {
      if (destinationPeerId != null && destinationPeerId.isNotEmpty) {
        await _joinAsClient(destinationPeerId, player);
        if (isPeerConnected) return;
      }
      for (var peerId in canditadesPeersId ?? []) {
        if (peerId != destinationPeerId) {
          await _joinAsClient(peerId, player);
          if (isPeerConnected) return;
        }
      }
      throw TimeoutException("[CLIENT] Não há host disponível.");
    } catch (e) {
      log("[CLIENT]Erro ao entrar no StarHub: $e");
      rethrow;
    }
  }

  void send(EventDTO event) {
    if (!isPeerConnected) {
      log("Erro ao enviar dados: StarHub não está conectado.");
      return;
    }
    if (!isHostAvailable) {
      log("Host indisponível — envio descartado.");
      return;
    }
    try {
      starHub.broadcast(event.toMap());
    } catch (e) {
      log("Erro ao disparar broadcast no StarHub: $e");
    }
  }

  /// [survivors] = peerIds vivos (SEM o host morto), na MESMA ordem em
  /// todos os clientes (ordem de entrada na mesa).
  Future<void> handleAbruptHostLoss(List<String> survivors) async {
  if (isHost) return;
  final vivos = survivors.where((id) => id != myPeerId).toList();
  if (vivos.isEmpty) return;             // fiquei sozinho: nada a eleger
  if (survivors.first != myPeerId) return; // não sou o líder

  // 1. Registrar conexões de saída em _connections. join() é a única API
  //    pública que chama _setupConnection (:559).
  for (final peerId in vivos) {
    if (starHub.hostPeerId == peerId) continue;
    final opened = starHub.onPeerConnected.firstWhere((id) => id == peerId);
    try {
      await starHub.join(peerId);
      await opened.timeout(const Duration(seconds: 5));
    } catch (e) {
      log("Falha ao reconectar com $peerId: $e");
    }
  }

  // 2. Só agora assumir: o announce precisa de conexões ABERTAS (:397).
  await starHub.create();
}

  /// Sai da rede. A ordem é o que faz funcionar.
  Future<void> destroy() async {
    if (_destroyed) return;
    _destroyed = true;

    // 1. leave(): se sou host, dispara a migração; depois fecha as conexões.
    //    O guard fica AQUI, e não no topo, pra não vazar os controllers.
    try {
      if (isPeerConnected) await starHub.leave();
    } catch (e) {
      log("Erro no leave do StarHub: $e");
    }

    // 2. dispose() — não close(). close() fecha só o emitter e deixa os
    //    canais abertos; é a origem do "Cannot add new events after calling close".
    try {
      starHub.dispose();
    } catch (e) {
      log("Erro no dispose do StarHub: $e");
    }

    // 3. dispose() do peer — não disconnect(). Este fecha os RTCPeerConnection.
    try {
      peer.dispose();
    } catch (e) {
      log("Erro no dispose do Peer: $e");
    }

    isPeerConnected = false;
    _hostAvailable = false;

    await _dataController.close();
    await _peerLeftController.close();
    await _newHostController.close();
  }
}