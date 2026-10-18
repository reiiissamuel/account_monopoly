import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/service/peer_connection_service.dart';
import 'package:peer_rtc/peer_rtc.dart';
import 'dart:developer';
import 'dart:async';

class ClientPeerConnectionService extends PeerConnectionService {
  DataConnection? connWithServer;
  String? lastConnectedHostId;
  
  Timer? _retryTimer;

  ClientPeerConnectionService({
    required super.gameProvider,
    required super.peer,
    super.myPeerId,
  }) : super(isServer: false);

  Future<void> connectToHost(
    String peerSourceId, {
    int retries = 3,
    int delaySeconds = 2,
  }) async {
    _retryTimer?.cancel();
    lastConnectedHostId = peerSourceId;

    if (connWithServer != null) {
      closeConnectionKeepingTarget();
    }

    log("Tentando conectar ao Host: $peerSourceId (Tentativas restantes: $retries)");
    try {
      connWithServer = peer.connect(peerSourceId);
    } catch (e) {
      log("Erro ao invocar peer.connect: $e");
    }

    // --- ADAPTAÇÃO PARA PEER_RTC: Uso de Streams Nativos ---
    connWithServer?.onOpen.listen((event) {
      isConnected = true;
      _retryTimer?.cancel();
      log("Conexão estabelecida com sucesso ao Host: $peerSourceId");

      final gameModel = gameProvider.gameModelDTO;
      if (gameModel != null) {
        gameProvider.eventComposer(
          type: EventType.joinTable,
          sourcePlayer: gameModel.player,
        );
      }
    });

    connWithServer?.onClose.listen((event) {
      log(PeerConnectionService.hostConnectionClosedMsg);

      if (retries > 0 && !isConnected) {
        closeConnectionKeepingTarget();
        log("Host ainda não está pronto. Tentando novamente em ${delaySeconds}s...");

        _retryTimer = Timer(Duration(seconds: delaySeconds), () {
          connectToHost(
            peerSourceId,
            retries: retries - 1,
            delaySeconds: delaySeconds + 1,
          );
        });
        return;
      }

      _retryTimer?.cancel();
      final targetPeerId = lastConnectedHostId ?? peerSourceId;
      closeConnection();

      Future.microtask(() {
        final gameModel = gameProvider.gameModelDTO;
        if (gameModel != null) {
          for (var player in gameModel.othersPlayers.values) {
            if (player.isHost || player.id == targetPeerId) {
              player.isOnline = false;
            }
          }

          final lostPlayer = gameModel.othersPlayers[targetPeerId];
          if (lostPlayer != null) {
            gameProvider.processComingEvent(
              EventDTO(
                type: EventType.lostConnection,
                sourcePlayer: lostPlayer,
                referenceRound: 0,
              ),
            );
          }
        }

        reconnectToLastHost();
      });
    });

    connWithServer?.onData.listen((data) {
      gameProvider.processComingEvent(EventDTO.fromMap(data));
    });
  }

  @override
  void send(EventDTO event) {
    if (!isConnected) {
      log("Erro ao enviar dados: Nenhuma conexão estabelecida.");
      return;
    }

    final mapData = event.toMap();
    if (connWithServer != null && connWithServer!.open) {
      connWithServer!.send(mapData);
    } else {
      log("Erro ao enviar dados: Conexão com o Host não está aberta.");
    }
  }

  void closeConnectionKeepingTarget() {
    isConnected = false;
    final localConn = connWithServer;
    connWithServer = null;
    
    if (localConn != null) {
      Future.microtask(() {
        try {
          localConn.close();
        } catch (_) {}
      });
    }
  }

  @override
  void closeConnection() {
    isConnected = false;
    _retryTimer?.cancel();
    final localConn = connWithServer;
    connWithServer = null;
    lastConnectedHostId = null;

    if (localConn != null) {
      Future.microtask(() {
        try {
          localConn.close();
        } catch (_) {}
      });
    }
    log("Conexões de Cliente encerradas localmente.");
  }

  @override
  void destroy() {
    _retryTimer?.cancel();
    closeConnection();
    try {
      peer.disconnect();
    } catch (e) {
      log("Erro ao desconectar o peer do cliente: $e");
    }
  }
}