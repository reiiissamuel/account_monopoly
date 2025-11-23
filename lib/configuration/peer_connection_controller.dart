import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:peerdart/peerdart.dart';
import 'dart:developer';


import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:peerdart/peerdart.dart';
import 'dart:developer';

class PeerConnectionController {
  String myPeerId;
  Peer peer;
  // Usamos 'late' para que a variável seja inicializada no connectToHost
  late DataConnection connWithServer;
  bool isConnected = false;
  bool isServer = false;
  GameProvider gameModelController;

  List<DataConnection> serverActiveConnections = <DataConnection>[];

  static const String OPENED_CONNECTION_MSG = "Peer aberto para conexões.";
  static const String CONNECTION_RECEIVED_MSG = "Nova conexão recebida do peer:";
  static const String PEER_CONNECTION_CLOSED = "Jogador offline:";
  static const String HOST_CONNECTION_CLOSED = "Host offline (Cliente):"; // Mensagem ajustada

  PeerConnectionController(
      {required this.gameModelController,
        required this.peer,
        required this.myPeerId});

  /// Inicializa o peer como um Host, pronto para receber conexões.
  void openConnectionsAsHost() {
    isServer = true;
    peer.on("open").listen((id) {
      isConnected = true;
      log(OPENED_CONNECTION_MSG);
    });

    peer.on("close").listen((id) {
      closeConnection();
      reconnect(); // Tenta reabrir a conexão Peer (importante se o PeerState fechar)
    });

    peer.on<DataConnection>("connection").listen((event) {
      // 1. Adiciona a nova conexão
      serverActiveConnections.add(event);

      // 2. Evento de abertura da conexão
      event.on("open").listen((_) { // O evento 'open' geralmente não passa dados úteis
        log('$CONNECTION_RECEIVED_MSG ${event.peer}');

        // Handshake: Apenas o Server precisa enviar o Handshake
        gameModelController.eventComposer(
            type: EventType.serverHandShake,
            destinationPlayer: Player.ofDefinedId(username: "", id: event.peer));
      });

      // 3. Recebimento de dados e retransmissão
      event.on("data").listen((data) {
        // Processa o evento localmente
        gameModelController.processComingEvent(EventDTO.fromMap(data));
        // Retransmite para os outros peers conectados
        send(EventDTO.fromMap(data));
      });

      // 4. Fechamento da conexão de um cliente
      event.on("close").listen((_) {
        // Encontra a conexão na lista de ativos
        serverActiveConnections.removeWhere((c) => c.peer == event.peer);
        log('$PEER_CONNECTION_CLOSED ${event.peer}');

        // Notifica o GameModel sobre a perda de conexão
        gameModelController.eventComposer(
            type: EventType.lostConnection,
            sourcePlayer: gameModelController.gameModelDTO!.othersPlayers[event.peer]);
      });

      event.on('disconnected').listen((_) {
        // 'disconnected' pode ocorrer antes do 'close', pode ser tratado aqui se necessário
        log("Peer ${event.peer} desconectado (em Host)");
      });

      isConnected = true;
    });
  }

  /// Conecta o peer atual como um Cliente a um Host
  Future<void> connectToHost(String peerSourceId) async {
    connWithServer = peer.connect(peerSourceId);

    // 1. Abertura da Conexão
    connWithServer.on("open").listen((event) {
      isConnected = true;
      log("Conectado ao Host: $peerSourceId");
    });

    // 2. Fechamento da Conexão (CORRIGIDO para não usar lógica de servidor)
    // Correção na função connectToHost:
    connWithServer.on("close").listen((event) {
      log(HOST_CONNECTION_CLOSED);
      closeConnection();

      final gameModel = gameModelController.gameModelDTO;

      // VERIFICAÇÃO DE SEGURANÇA: Garante que o modelo do jogo exista
      if (gameModel != null) {
        // 1. Tenta encontrar o jogador na lista
        final lostPlayer = gameModel.othersPlayers[connWithServer.peer];

        // 2. Se o jogador for encontrado, envia o evento de desconexão
        if (lostPlayer != null) {
          gameModelController.processComingEvent(
            EventDTO(
              type: EventType.lostConnection,
              sourcePlayer: lostPlayer,
              referenceRound: 0
            ),
          );
        } else {
          log("Aviso: Jogador perdido não encontrado em othersPlayers. ID: ${connWithServer.peer}");
          // Se não for encontrado, o jogo deve tratar o remapeamento dos peers mesmo assim.
          // Você pode querer criar um Player temporário aqui se o ID for crítico.
        }
      } else {
        log("Erro: GameModelDTO nulo durante a desconexão do Host.");
      }

      reconnect();
    });

    // 3. Recebimento de dados
    connWithServer.on("data").listen((data) {
      gameModelController.processComingEvent(EventDTO.fromMap(data));
    });

    connWithServer.on('disconnected').listen((event) {
      log("Desconectado do Host");
      // O evento 'close' deve ser acionado em seguida.
    });
  }

  Future<bool> _hasInternet() async {
    // Nota: connectivity_plus é bom para verificar conexão com a internet,
    // mas não garante que o servidor PeerJS (ou o Host local) esteja acessível.
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      closeConnection();
      return false;
    }
    return isConnected;
  }

  void closeConnection() {
    if (isServer) {
      // Fecha todas as conexões ativas antes de limpar
      for (var conn in serverActiveConnections) {
        conn.close();
      }
      serverActiveConnections = [];
      isServer = false;
    } else if (isConnected && connWithServer.open) {
      // Fecha a conexão com o Host se for cliente
      connWithServer.close();
    }
    // Opcional: Chama dispose, o que fecha o próprio Peer ID.
    peer.dispose();
    isConnected = false;
  }

  // Correção na função reconnect:
  void reconnect() {
    final gameModel = gameModelController.gameModelDTO;

    if (gameModel == null) {
      log("GameModelDTO nulo. Não é possível determinar o próximo Host. Assumindo Host.");
      openConnectionsAsHost();
      return;
    }

    // A lógica original de reconexão
    try{
      String nextPeerId = _getNextServerCandidatePeerId();
      if (myPeerId == nextPeerId) {
        openConnectionsAsHost();
      } else {
        connectToHost(nextPeerId);
      }
    } on StateError {
      // Se a lógica de nextPeerId falhar (ex: lista vazia), torna-se Host.
      openConnectionsAsHost();
    } catch (e) {
      log("Erro inesperado na reconexão: $e. Assumindo Host.");
      openConnectionsAsHost();
    }
  }

  /// Determina o próximo Host de forma determinística (ID mais baixo)
  String _getNextServerCandidatePeerId() {
    // 1. Pega todos os IDs dos jogadores, exceto o ID próprio (se estiver na lista othersPlayers)
    List<String> peerIds = gameModelController.gameModelDTO!.othersPlayers.keys.toList();

    // 2. Inclui o ID do próprio peer, pois ele pode ser o próximo Host.
    peerIds.add(myPeerId);

    // 3. Ordena os IDs de forma determinística (alfabética/numérica)
    peerIds.sort();

    // 4. O próximo Host é aquele com o menor ID na lista ordenada.
    // Isso garante que todos os peers concordem em quem é o novo Host.
    return peerIds.first;
  }

  void send(EventDTO event) {
    if (isServer) {
      // Retransmissão: Envia para todos, exceto a fonte
      for (DataConnection dataConnection in serverActiveConnections) {
        if (dataConnection.peer != event.sourcePlayer.id) {
          dataConnection.send(event.toMap());
        }
      }
    } else if (isConnected && connWithServer.open) {
      // Cliente: Envia apenas para o Host
      connWithServer.send(event.toMap());
    } else {
      log("Tentativa de envio falhou: não conectado ou não Host.");
    }
  }
}
