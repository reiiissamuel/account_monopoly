import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/service/peer_connection_service.dart';
import 'package:peerdart/peerdart.dart';
import 'dart:developer';

class ClientPeerConnectionService extends PeerConnectionService {
  DataConnection? connWithServer;

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
    if (connWithServer != null) {
      connWithServer?.close();
      connWithServer = null;
    }

    log("Tentando conectar ao Host: $peerSourceId (Tentativas restantes: $retries)");
    connWithServer = peer.connect(peerSourceId);

    connWithServer!.on("open").listen((event) {
      isConnected = true;
      log("Conectado com sucesso ao Host: $peerSourceId");

      final gameModel = gameProvider.gameModelDTO;
      if (gameModel != null) {
        gameProvider.eventComposer(
          type: EventType.joinTable,
          sourcePlayer: gameModel.player,
        );
      }
    });

    connWithServer!.on("close").listen((event) {
      log(PeerConnectionService.hostConnectionClosedMsg);

      if (retries > 0 && !isConnected) {
        closeConnection();
        log("Host ainda não está pronto. Tentando novamente em ${delaySeconds}s...");

        Future.delayed(Duration(seconds: delaySeconds), () {
          connectToHost(
            peerSourceId,
            retries: retries - 1,
            delaySeconds: delaySeconds + 1,
          );
        });
        return;
      }

      closeConnection();

      final gameModel = gameProvider.gameModelDTO;
      if (gameModel != null) {
        final lostPlayer = gameModel.othersPlayers[connWithServer?.peer];
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

      // Invocação direta do método herdado da classe pai
      reconnectToLastHost();
    });

    connWithServer!.on("data").listen((data) {
      gameProvider.processComingEvent(EventDTO.fromMap(data));
    });

    connWithServer!.on('disconnected').listen((event) {
      log("Desconectado temporariamente do Host. Tentando restabelecer...");
      reconnectToLastHost();
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

  @override
  void closeConnection() {
    isConnected = false;
    connWithServer?.close();
    connWithServer = null;
    log("Conexões de Cliente encerradas localmente.");
  }

  @override
  void destroy() {
    closeConnection();
    try {
      peer.disconnect();
    } catch (e) {
      log("Erro ao desconectar o peer do cliente: $e");
    }
  }
}