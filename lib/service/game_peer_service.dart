import 'package:account_monopoly/domain/model/event_dto.dart';
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
    starHub.onData.listen((eventData) {
      try {
        // O StarHub costuma estruturar o payload. Ajuste conforme o formato emitido pela lib.
        final mapData = eventData['data'] ?? eventData;
        if (mapData is Map<String, dynamic>) {
          gameProvider.processComingEvent(EventDTO.fromMap(mapData));
        }
      } catch (e) {
        log("Erro ao processar dados recebidos no StarHub: $e");
      }
    });

    // Evento nativo de mudança/migração de host fornecido pela biblioteca!
    starHub.onHostChanged.listen((newHostId) {
      log("Migração de Host detectada pelo StarHub. Novo host: $newHostId");
      
      final gameModel = gameProvider.gameModelDTO;
      if (gameModel != null) {
        gameModel.player.isHost = (newHostId == myPeerId);
        
        // Atualiza o status online/host dos outros jogadores na mesa
        for (var player in gameModel.othersPlayers.values) {
          player.isHost = (player.id == newHostId);
        }
      }
    });

    starHub.onPeerJoined.listen((entry) {
      log("Jogador conectado à rede StarHub: ${entry.peerId}");
    });

    starHub.onPeerLeft.listen((peerId) {
      log("Jogador desconectado da rede StarHub: $peerId");
    });
  }

  /// Inicializa como Host da mesa
  Future<void> startAsHost() async {
    try {
      await starHub.create();
      isConnected = true;
      log("StarHub Host iniciado com sucesso. ID: $myPeerId");
    } catch (e) {
      log("Erro ao iniciar StarHub como Host: $e");
      rethrow;
    }
  }

  /// Inicializa entrando como Cliente em um Host existente
  Future<void> joinAsClient(String hostPeerId) async {
    try {
      await starHub.join(hostPeerId);
      isConnected = true;
      log("Conectado com sucesso ao StarHub do Host: $hostPeerId");
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