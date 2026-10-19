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
  
  bool isConnected = false;
  String myPeerId;
  bool isServer;

  GamePeerService({
    required this.gameProvider,
    required this.peer,
    required this.myPeerId,
    required this.isServer,
  }) {
    starHub = StarHub(peer: peer);
    _initListeners();
  }

  void _initListeners() {
    // Escuta dados recebidos de qualquer nó na rede StarHub
    starHub.onData.listen((e) {
      log("Dados recebidos do StarHub: $e");
      try {
        gameProvider.processComingEvent(EventDTO.fromMap(e['data']));
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

    starHub.onPeerJoined.listen((entry) {
      log("Jogador conectado à rede StarHub: ${entry.peerId}");
    });

    starHub.onPeerLeft.listen((entry) {
      log("Jogador desconectado da rede StarHub: ${entry.peerId}"); // Usando .peerId
    });
  }

  /// Inicializa como Host da mesa
  Future<void> startAsHost() async {
    // Inicializa o StarHub como servidor
    await starHub.create();

    // Escuta quando novos peers entram na estrela
    starHub.onPeerJoined.listen((peerId) {
      log("Novo peer conectado ao StarHub Host: $peerId");
    });

    // CRUCIAL: Certifique-se de que o onData global do StarHub está ativo
    starHub.onData.listen((incomingData) {
      log("Dados recebidos no Host: $incomingData");
      final event = EventDTO.fromMap(incomingData);
      gameProvider.processComingEvent(event);
    });
  }

  /// Inicializa entrando como Cliente em um Host existente
  Future<void> joinAsClient(String hostPeerId, Player localPlayer) async {
    try {
      await starHub.join(hostPeerId);
      isConnected = true;
      log("Conectado com sucesso ao StarHub do Host: $hostPeerId");

      final joinEvent = EventDTO(
        referenceRound: 1,
        type: EventType.joinTable,
        sourcePlayer: localPlayer,
      );
      
      send(joinEvent);
      log("Evento joinTable disparado pelo cliente para o host.");
    } catch (e) {
      log("Erro ao entrar no StarHub do Host: $e");
      rethrow;
    }
  }

  /// Envia/Faz o broadcast de eventos para toda a mesa através do StarHub
  void send(EventDTO event) {
    if (!isConnected) {
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
      isConnected = false;
    }
  }
}