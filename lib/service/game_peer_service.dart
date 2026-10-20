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
  bool isServer = false;

  // Streams públicas para notificar o Provider sem acoplamento
  final _dataController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onData => _dataController.stream;

  final _peerLeftController = StreamController<String>.broadcast();
  Stream<String> get onPeerLeft => _peerLeftController.stream;

  static const hostReceivedMessage = "[HOST] Dados recebidos do StarHub do peer";
  static const clientReceivedMessage = "[CLIENT] Dados recebidos do StarHub do peer";

  GamePeerService({
    required this.peer,
    required this.myPeerId,
  }) {
    starHub = StarHub(peer: peer);
    _initListeners();
  }

  void _initListeners() {
    starHub.onData.listen((incomingData) {
      final emitterPeerId = incomingData['from'];
      if(emitterPeerId == myPeerId) return;
      try {
        if (isServer) {
          log("$hostReceivedMessage $emitterPeerId");
        } else {
          log("$clientReceivedMessage $emitterPeerId");
        }
        
        // Emite o dado bruto para quem estiver ouvindo a Stream
        _dataController.add(incomingData);
      } catch (e) {
        log("Erro ao processar dados recebidos no StarHub: $e");
      }
    });

    starHub.onHostChanged.listen((newHostId) {
      log("Aviso do StarHub - Host atualizado na rede: $newHostId");
      isServer = (newHostId == myPeerId);
    });

    starHub.onPeerJoined.listen((entry) {
      log("Novo peer conectado ao StarHub Host: ${entry.peerId}");
    });

    starHub.onPeerLeft.listen((entry) {
      log("Peer desconectado da rede StarHub: ${entry.peerId}");
      // Emite o ID do peer que saiu
      _peerLeftController.add(entry.peerId);
    });
  }

  Future<void> startAsHost() async {
    await starHub.create();
    log("Criação do StarHub como Host concluída.");
    isPeerConnected = true;
    isServer = true;
  }

  Future<void> _joinAsClient(String hostPeerId, Player localPlayer) async {
    try {
      final hostReady = starHub.onPeerConnected.firstWhere((connectedPeerId) => connectedPeerId == hostPeerId);
      await starHub.join(hostPeerId);
      await hostReady.timeout(const Duration(seconds: 5));
      isPeerConnected = true;
      log("Conectado com sucesso ao StarHub do Host: $hostPeerId");

      final joinEvent = EventDTO(
        referenceRound: 1,
        type: EventType.joinTable,
        sourcePlayer: localPlayer,
      );
      
      send(joinEvent);
      log("Evento joinTable disparado pelo cliente para o host.");
    } on TimeoutException {
      isPeerConnected = false;
      log("Timeout ao tentar conexão com o host candidate: $hostPeerId");
    } catch (e) {
      isPeerConnected = false;
      log("Erro ao entrar no StarHub do Host: $e");
    } finally {
      isServer = false;
    }
  }

  Future<void> connectToHost({required Player player, String? destinationPeerId, List<String>? canditadesPeersId}) async {
    try {
      if (destinationPeerId != null && destinationPeerId.isNotEmpty) {
        await _joinAsClient(destinationPeerId, player);
        if(isPeerConnected) return;
      }
      for (var peerId in canditadesPeersId ?? []){
          if (peerId != destinationPeerId) {
            await _joinAsClient(peerId, player);
            if(isPeerConnected) return;
          }
      }
      throw TimeoutException("Não há host disponível.");
    } catch (e) {
      log("Erro ao entrar no StarHub: $e");
      rethrow;
    }
  }

  void send(EventDTO event) {
    if (!isPeerConnected) {
      log("Erro ao enviar dados: StarHub não está conectado.");
      return;
    }
    try {
      starHub.broadcast(event.toMap());
    } catch (e) {
      log("Erro ao disparar broadcast no StarHub: $e");
    }
  }

  void destroy() {
    _dataController.close();
    _peerLeftController.close();
    try {
      starHub.close();
      peer.disconnect();
    } catch (e) {
      log("Erro ao destruir o serviço StarHub: $e");
    } finally {
      isPeerConnected = false;
    }
  }
}