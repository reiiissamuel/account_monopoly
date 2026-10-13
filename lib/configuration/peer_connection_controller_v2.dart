import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:peerdart/peerdart.dart';
import 'dart:developer';

class PeerConnectionControllerV2 {
  String myPeerId;
  Peer peer;
  DataConnection? connWithServer;
  bool isConnected = false;
  bool isServer = false;
  GameProvider gameModelController;

  List<DataConnection> serverActiveConnections = <DataConnection>[];
  bool _isHostListenersInitialized = false; // Impede duplicação de listeners em reconexões

  static const String OPENED_CONNECTION_MSG = "Peer aberto para conexões.";
  static const String CONNECTION_RECEIVED_MSG = "Nova conexão recebida do peer:";
  static const String PEER_CONNECTION_CLOSED = "Jogador offline:";
  static const String HOST_CONNECTION_CLOSED = "Host offline (Cliente):";

  PeerConnectionControllerV2({
    required this.gameModelController,
    required this.peer,
    this.myPeerId = '', // Opcional, pois o ID real é atribuído pelo evento open do PeerJS
  });

  /// Inicializa o peer como um Host, pronto para receber conexões.
  void openConnectionsAsHost() {
    isServer = true;

    // Evita registrar os listeners múltiplas vezes se o fallback for acionado
    if (_isHostListenersInitialized) {
      log("Listeners do Host já inicializados. Ignorando re-registro.");
      return;
    }
    _isHostListenersInitialized = true;

    peer.on("open").listen((id) {
      isConnected = true;
      myPeerId = id;
      log("$OPENED_CONNECTION_MSG ID: $myPeerId");
    });

    peer.on("close").listen((_) {
      closeConnection();
      reconnectToLastHost(); 
    });

    peer.on<DataConnection>("connection").listen((event) {
      serverActiveConnections.add(event);

      event.on("open").listen((_) {
        log('$CONNECTION_RECEIVED_MSG ${event.peer}');

        // Handshake original mantido: Apenas o Server precisa enviar o Handshake
        gameModelController.eventComposer(
          type: EventType.serverHandShake,
          destinationPlayer: Player.ofDefinedId(username: "", id: event.peer),
        );
      });

      event.on("data").listen((data) {
        // Processa o evento localmente
        gameModelController.processComingEvent(EventDTO.fromMap(data));
        // Retransmite para os outros peers conectados (Loop de distribuição do host)
        sendToAll(EventDTO.fromMap(data));
      });

      event.on("close").listen((_) {
        serverActiveConnections.removeWhere((c) => c.peer == event.peer);
        log('$PEER_CONNECTION_CLOSED ${event.peer}');

        final gameModel = gameModelController.gameModelDTO;
        if (gameModel != null && gameModel.othersPlayers.containsKey(event.peer)) {
          gameModelController.eventComposer(
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

  /// Conecta o peer atual como um Cliente a um Host
  Future<void> connectToHost(String peerSourceId) async {
    isServer = false;
    
    // Fecha conexões anteriores ativas antes de abrir uma nova
    if (connWithServer != null) {
      connWithServer?.close();
      connWithServer = null;
    }

    connWithServer = peer.connect(peerSourceId);

    connWithServer!.on("open").listen((event) {
      isConnected = true;
      log("Conectado ao Host: $peerSourceId");
    });

    connWithServer!.on("close").listen((event) {
      log(HOST_CONNECTION_CLOSED);
      closeConnection(); 

      final gameModel = gameModelController.gameModelDTO;

      if (gameModel != null) {
        final lostPlayer = gameModel.othersPlayers[connWithServer?.peer];

        if (lostPlayer != null) {
          gameModelController.processComingEvent(
            EventDTO(
              type: EventType.lostConnection,
              sourcePlayer: lostPlayer,
              referenceRound: 0,
            ),
          );
        } else {
          log("Aviso: Jogador perdido não encontrado em othersPlayers. ID: ${connWithServer?.peer}");
        }
      } else {
        log("Erro: GameModelDTO nulo durante a desconexão do Host.");
      }

      // Dispara a lógica de eleição de novo host
      reconnectToLastHost();
    });

    connWithServer!.on("data").listen((data) {
      gameModelController.processComingEvent(EventDTO.fromMap(data));
    });

    connWithServer!.on('disconnected').listen((event) {
      log("Desconectado temporariamente do Host. Tentando restabelecer...");
      reconnectToLastHost();
    });
  }

  /// Envia dados para todos os clientes conectados (Usado apenas se for Host)
  void sendToAll(EventDTO event) {
    if (!isServer) return;
    final mapData = event.toMap();
    for (var connection in serverActiveConnections) {
      if (connection.open) {
        connection.send(mapData);
      }
    }
  }

  /// Limpa as conexões atuais de forma segura
  void closeConnection() {
    isConnected = false;
    if (isServer) {
      for (var conn in serverActiveConnections) {
        conn.close();
      }
      serverActiveConnections.clear();
      _isHostListenersInitialized = false; // Permite reabrir o host limpo se necessário
    } else {
      connWithServer?.close();
      connWithServer = null;
    }
    log("Conexões encerradas localmente.");
  }

  /// Lógica Determinística para Eleição de um Novo Host
  void reconnectToLastHost() {
    final gameModel = gameModelController.gameModelDTO;

    if (gameModel == null || gameModel.othersPlayers.isEmpty) {
      log("Nenhum dado de jogo ou jogadores disponíveis. Assumindo Host.");
      openConnectionsAsHost();
      return;
    }

    try {
      final activePlayers = gameModel.othersPlayers.values.toList();

      if (activePlayers.isEmpty) {
        log("Nenhum outro jogador restante. Assumindo Host.");
        openConnectionsAsHost();
        return;
      }

      // 1. ORDENAÇÃO DETERMINÍSTICA: O menor ID alfabético ganha
      activePlayers.sort((a, b) => a.id.compareTo(b.id));

      // 2. O primeiro da lista é o novo líder unânime
      final newHostPlayer = activePlayers.first;

      log("Eleição concluída. Novo Host eleito por consenso: ${newHostPlayer.id}");

      // 3. ATUALIZAÇÃO DA VARIÁVEL isHost EM TODOS OS JOGADORES DO MODELO
      gameModel.player.isHost = (gameModel.player.id == newHostPlayer.id);
      for (var player in gameModel.othersPlayers.values) {
        player.isHost = (player.id == newHostPlayer.id);
      }

      // 4. Define o comportamento de rede baseado em quem venceu
      if (newHostPlayer.id == myPeerId) {
        log("Eu fui eleito o novo Host da mesa. Abrindo conexões...");
        openConnectionsAsHost();
      } else {
        log("Tentando se conectar automaticamente ao novo Host eleito: ${newHostPlayer.id}");
        connectToHost(newHostPlayer.id);
      }
    } catch (e) {
      log("Falha crítica no processo de eleição de Host: ", error: e);
      openConnectionsAsHost();
    }
  }

  /// Verifica se há conectividade de hardware local
  Future<bool> hasInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Envia um evento. Se for Host, repassa para todos os clientes. 
  /// Se for Cliente, envia diretamente para o Host.
  void send(EventDTO event) {
    if (!isConnected) {
      log("Erro ao enviar dados: Nenhuma conexão estabelecida.");
      return;
    }

    final mapData = event.toMap();

    if (isServer) {
      // Se eu sou o Host, distribuo a mensagem para todo mundo na mesa
      sendToAll(event);
    } else {
      // Se eu sou um Cliente comum, envio minha jogada apenas para o Host
      if (connWithServer != null && connWithServer!.open) {
        connWithServer!.send(mapData);
      } else {
        log("Erro ao enviar dados: Conexão com o Host não está aberta.");
      }
    }
  }
}