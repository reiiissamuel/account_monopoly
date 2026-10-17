import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/service/peer_connection_service.dart';
import 'package:peerdart/peerdart.dart';
import 'dart:developer';

class HostPeerConnectionService extends PeerConnectionService {
  List<DataConnection> serverActiveConnections = <DataConnection>[];
  bool _isHostListenersInitialized = false;

  HostPeerConnectionService({
    required super.gameProvider,
    required super.peer,
    super.myPeerId,
  }) : super(isServer: true);

  void openConnectionsAsHost() {
    if (_isHostListenersInitialized) {
      log("Listeners do Host já inicializados. Ignorando re-registro.");
      return;
    }
    _isHostListenersInitialized = true;

    peer.on("open").listen((id) {
      isConnected = true;
      myPeerId = id;
      log("${PeerConnectionService.openedConnectionMsg} ID: $myPeerId");
    });

    peer.on("close").listen((_) {
      closeConnection();
      reconnectToLastHost(); // Chama o método herdado da classe pai
    });

    peer.on<DataConnection>("connection").listen((event) {
      serverActiveConnections.add(event);

      event.on("open").listen((_) {
        log('Nova conexão recebida do peer: ${event.peer}');
        handleIncomingPeerConnection(event.peer);
      });

      event.on("data").listen((data) {
        gameProvider.processComingEvent(EventDTO.fromMap(data));
        sendToAll(EventDTO.fromMap(data));
      });

      event.on("close").listen((_) {
        serverActiveConnections.removeWhere((c) => c.peer == event.peer);
        log('${PeerConnectionService.peerConnectionClosedMsg} ${event.peer}');

        final gameModel = gameProvider.gameModelDTO;
        if (gameModel != null && gameModel.othersPlayers.containsKey(event.peer)) {
          gameProvider.eventComposer(
            type: EventType.lostConnection,
            sourcePlayer: gameModel.othersPlayers[event.peer],
          );
        }
      });

      event.on('disconnected').listen((_) {
        log("Peer ${event.peer} desconectado temporariamente (em Host)");
        serverActiveConnections.removeWhere((c) => c.peer == event.peer);
      });

      isConnected = true;
    });
  }

  void sendToAll(EventDTO event) {
    final mapData = event.toMap();
    for (var connection in serverActiveConnections) {
      if (connection.open) {
        connection.send(mapData);
      }
    }
  }

  @override
  void send(EventDTO event) {
    if (!isConnected) {
      log("Erro ao enviar dados: Nenhuma conexão estabelecida.");
      return;
    }
    sendToAll(event);
  }

  @override
  void closeConnection() {
    isConnected = false;
    for (var conn in serverActiveConnections) {
      conn.close();
    }
    serverActiveConnections.clear();
    _isHostListenersInitialized = false;
    log("Conexões de Host encerradas localmente.");
  }

  @override
  void destroy() {
    closeConnection();
    try {
      peer.disconnect();
    } catch (e) {
      log("Erro ao desconectar o peer do host: $e");
    }
  }

  void handleIncomingPeerConnection(String incomingPeerId) {
    final gameModel = gameProvider.gameModelDTO;
    if (gameModel == null) return;

    final incomingBaseId = extractBaseIdentifier(incomingPeerId);
    final extractedUsername = incomingPeerId.split('-').isNotEmpty ? incomingPeerId.split('-')[0] : '';

    if (incomingBaseId != null) {
      String? existingKey;
      Player? existingPlayer;

      for (var entry in gameModel.othersPlayers.entries) {
        if (extractBaseIdentifier(entry.key) == incomingBaseId) {
          existingKey = entry.key;
          existingPlayer = entry.value;
          break;
        }
      }

      if (existingKey != null && existingPlayer != null) {
        log("Reconexão detectada no Novo Host para: ${existingPlayer.username}. Atualizando ID.");
        gameModel.othersPlayers.remove(existingKey);

        Player updatedPlayer = existingPlayer.copyWith(
          id: incomingPeerId,
          isOnline: true,
        );

        gameModel.othersPlayers[incomingPeerId] = updatedPlayer;

        gameProvider.eventComposer(
          type: EventType.serverHandShake,
          destinationPlayer: updatedPlayer,
        );
        return;
      }
    }

    final newPlayer = Player.ofDefinedId(
      username: extractedUsername,
      id: incomingPeerId,
    );
    newPlayer.currentCredit = gameModel.initalGameCredit;
    newPlayer.isOnline = true;

    gameModel.othersPlayers[incomingPeerId] = newPlayer;

    gameProvider.eventComposer(
      type: EventType.serverHandShake,
      destinationPlayer: newPlayer,
    );
  }
}