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

  static const String openedConnectionMsg = "Peer aberto para conexões.";
  static const String connectionReceivedMsg = "Nova conexão recebida do peer:";
  static const String peerConnectionClosedMsg = "Jogador offline:";
  static const String hostConnectionClosedMsg = "Host offline (Cliente):";

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
      log("$openedConnectionMsg ID: $myPeerId");
    });

    peer.on("close").listen((_) {
      _closeConnection();
      reconnectToLastHost(); 
    });

    peer.on<DataConnection>("connection").listen((event) {
      serverActiveConnections.add(event);

      event.on("open").listen((_) {
        log('$connectionReceivedMsg ${event.peer}');
        handleIncomingPeerConnection(event.peer);
      });

      event.on("data").listen((data) {
        // Processa o evento localmente
        gameModelController.processComingEvent(EventDTO.fromMap(data));
        // Retransmite para os outros peers conectados (Loop de distribuição do host)
        sendToAll(EventDTO.fromMap(data));
      });

      event.on("close").listen((_) {
        serverActiveConnections.removeWhere((c) => c.peer == event.peer);
        log('$peerConnectionClosedMsg ${event.peer}');

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

  /// Conecta o peer atual como um Cliente a um Host com suporte a tentativas automáticas (retry)
  Future<void> connectToHost(String peerSourceId, {int retries = 3, int delaySeconds = 2}) async {
    isServer = false;
    
    // Fecha conexões anteriores ativas antes de abrir uma nova
    if (connWithServer != null) {
      connWithServer?.close();
      connWithServer = null;
    }

    log("Tentando conectar ao Host: $peerSourceId (Tentativas restantes: $retries)");
    connWithServer = peer.connect(peerSourceId);

    connWithServer!.on("open").listen((event) {
      isConnected = true;
      log("Conectado com sucesso ao Host: $peerSourceId");
    });

    connWithServer!.on("close").listen((event) {
      log(hostConnectionClosedMsg);
      
      // Se fechou e o cliente nunca chegou a estabelecer o estado 'isConnected' com sucesso,
      // significa que o host eleito ainda não abriu o servidor PeerJS a tempo. Fazemos o retry.
      if (retries > 0 && !isConnected) {
        _closeConnection();
        log("Host ainda não está pronto. Tentando novamente em ${delaySeconds}s...");
        
        Future.delayed(Duration(seconds: delaySeconds), () {
          connectToHost(peerSourceId, retries: retries - 1, delaySeconds: delaySeconds + 1);
        });
        return;
      }

      // Se já estava conectado e caiu depois, ou esgotou as tentativas, segue o fluxo normal de queda
      _closeConnection(); 

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

      // Dispara a lógica de eleição de novo host novamente se esgotar
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
  void _closeConnection() {
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

    if (gameModel == null) {
      log("Nenhum dado de jogo disponível. Assumindo Host.");
      openConnectionsAsHost();
      return;
    }

    try {
      gameModel.othersPlayers.removeWhere((id, player) => player.isHost);

      final activePlayers = gameModel.othersPlayers.values.toList();

      if (activePlayers.isEmpty) {
        log("Nenhum outro jogador restante na mesa. Assumindo Host.");
        openConnectionsAsHost();
        return;
      }
      // Adiciona o próprio jogador à lista de elegíveis para a eleição unânime
      activePlayers.add(gameModel.player);
      // 2. ORDENAÇÃO DETERMINÍSTICA: O menor ID alfabético ganha por consenso
      activePlayers.sort((a, b) => a.id.compareTo(b.id));
      // 3. O primeiro da lista ordenada é o novo líder unânime da mesa
      final newHostPlayer = activePlayers.first;

      log("Eleição concluída. Novo Host eleito por consenso: ${newHostPlayer.id}");

      // 4. ATUALIZAÇÃO DA VARIÁVEL isHost EM TODOS OS JOGADORES DO MODELO
      gameModel.player.isHost = (gameModel.player.id == newHostPlayer.id);
      for (var player in gameModel.othersPlayers.values) {
        player.isHost = (player.id == newHostPlayer.id);
      }
      // 5. Define o comportamento de rede baseado em quem venceu a eleição
      if (newHostPlayer.id == myPeerId) {
        log("Eu fui eleito o novo Host da mesa. Abrindo conexões como servidor...");
        openConnectionsAsHost();
      } else {
        log("Tentando se conectar automaticamente ao novo Host eleito: ${newHostPlayer.id}");
        // ADICIONE ESTE ATRASO DE 2 SEGUNDOS:
        // Dá tempo suficiente para o novo host eleito inicializar o servidor PeerJS antes do cliente tentar o handshake
        Future.delayed(const Duration(seconds: 2), () {
          connectToHost(newHostPlayer.id);
        });
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

  /// Analisa a conexão recebida e trata caso seja uma reconexão ou um novo jogador
  void handleIncomingPeerConnection(String incomingPeerId) {
    final gameModel = gameModelController.gameModelDTO;
    if (gameModel == null) return;

    final incomingParts = incomingPeerId.split('-');
    
    if (incomingParts.length >= 2) {
      final baseIdentifier = '${incomingParts[0]}-${incomingParts[1]}';
      final extractedUsername = incomingParts[0];

      String? existingKey;
      Player? existingPlayer;

      // Procura se já existe um jogador com a mesma base (mesmo usuário que caiu e voltou)
      for (var entry in gameModel.othersPlayers.entries) {
        final existingParts = entry.key.split('-');
        if (existingParts.length >= 2) {
          final existingBaseId = '${existingParts[0]}-${existingParts[1]}';
          if (existingBaseId == baseIdentifier) {
            existingKey = entry.key;
            existingPlayer = entry.value;
            break;
          }
        }
      }

      // CASO 1: Jogador reconectado após um crash (Usa o copyWith para substituir o ID sem perder o estado)
      if (existingKey != null && existingPlayer != null && existingKey != incomingPeerId) {
        log("Jogador reconectado detetado: ${existingPlayer.username}. Atualizando PeerID de $existingKey para $incomingPeerId");

        gameModel.othersPlayers.remove(existingKey);

        // Chamada limpa que substitui o Player.ofDefinedId e preserva todo o histórico
        Player updatedPlayer = existingPlayer.copyWith(id: incomingPeerId);

        gameModel.othersPlayers[incomingPeerId] = updatedPlayer;

        gameModelController.eventComposer(
          type: EventType.serverHandShake,
          destinationPlayer: updatedPlayer,
        );
        return;
      }

      // CASO 2: Jogador totalmente novo
      final newPlayer = Player.ofDefinedId(
        username: extractedUsername,
        id: incomingPeerId,
      );
      newPlayer.currentCredit = gameModel.initalGameCredit;

      gameModelController.eventComposer(
        type: EventType.serverHandShake,
        destinationPlayer: newPlayer,
      );
    }
  }

  /// Desconecta a instância atual do peer de forma segura e limpa as conexões ativas
  void destroy() {
    _closeConnection();
    try {
      peer.disconnect();
    } catch (e) {
      log("Erro ao desconectar o peer anterior: $e");
    }
  }
  
}