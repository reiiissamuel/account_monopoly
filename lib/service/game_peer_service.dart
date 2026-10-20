import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:peer_rtc/peer_rtc.dart';
import 'dart:developer';

class GamePeerService {
  final GameProvider gameProvider;
  final Peer peer;
  late StarHub starHub;
  
  bool isPeerConnected = false;
  String myPeerId;

  static const hostReceivedMessage = "[HOST] Dados recebidos do StarHub do peer";
  static const clientReceivedMessage = "[CLIENT] Dados recebidos do StarHub do peer";

  GamePeerService({
    required this.gameProvider,
    required this.peer,
    required this.myPeerId
  }) {
    starHub = StarHub(peer: peer);
    _initListeners();
  }

  bool get isServer => gameProvider.gameModelDTO?.player.isHost ?? false;

  void _initListeners() {
    // Escuta dados recebidos de qualquer nó na rede StarHub
    starHub.onData.listen((incomingData) {
      final emitterPeerId = incomingData['from'];
      if(emitterPeerId == myPeerId) return;
      try {
        if (isServer) {
          log("$hostReceivedMessage $emitterPeerId");
        } else {
          log("$clientReceivedMessage $emitterPeerId");
        }
        
        gameProvider.processComingEvent(EventDTO.fromMap(incomingData['data']));
      } catch (e) {
        log("Erro ao processar dados recebidos no StarHub: $e");
      }
    });

    // Evento nativo de mudança/migração de host fornecido pela biblioteca!
    starHub.onHostChanged.listen((newHostId) {
      log("Aviso do StarHub - Host atualizado na rede: $newHostId");
      
      final gameModel = gameProvider.gameModelDTO;
      if (gameModel != null) {
        final bool isNowHost = (newHostId == myPeerId);
        gameModel.player.isHost = isNowHost;
        
        for (var player in gameModel.othersPlayers.values) {
          player.isHost = (player.id == newHostId);
        }
      }
    });

    // os listeners abaixo são interpretados apenas pelo
    starHub.onPeerJoined.listen((entry) {
      log("Novo peer conectado ao StarHub Host: ${entry.peerId}");
    });

    starHub.onPeerLeft.listen((entry) {
      log("Peer desconectado da rede StarHub: ${entry.peerId}");
      gameProvider.eventComposer(
        type: EventType.lostConnection, 
        sourcePlayer: gameProvider.gameModelDTO?.othersPlayers[entry.peerId]
      );
    });
  }

  /// Inicializa como Host da mesa
  Future<void> startAsHost() async {
    // Inicializa o StarHub como servidor
    await starHub.create();
    log("Criação do StarHub como Host concluída.");
    isPeerConnected = true;
  }

  /// Inicializa entrando como Cliente em um Host existente
  Future<void> joinAsClient(String hostPeerId, Player localPlayer) async {
    try {
      final hostReady = starHub.onPeerConnected.firstWhere((peerId) => peerId == hostPeerId);
      await starHub.join(hostPeerId);
      await hostReady.timeout(const Duration(seconds: 15));
      isPeerConnected = true;
      log("Conectado com sucesso ao StarHub do Host: $hostPeerId");

      final joinEvent = EventDTO(
        referenceRound: 1,
        type: EventType.joinTable,
        sourcePlayer: localPlayer,
      );
      
      send(joinEvent);
      log("Evento joinTable disparado pelo cliente para o host.");
    } catch (e) {
      isPeerConnected = false;
      log("Erro ao entrar no StarHub do Host: $e");
      rethrow;
    }
  }

  /// Envia/Faz o broadcast de eventos para toda a mesa através do StarHub
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

  /// Encerra as conexões e limpa os recursos
  void destroy() {
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