import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:peerdart/peerdart.dart';
import 'dart:developer';

abstract class PeerConnectionService {
  String myPeerId;
  Peer peer;
  bool isConnected = false;
  bool isServer;
  GameProvider gameProvider;

  static const String openedConnectionMsg = "Peer aberto para conexões.";
  static const String peerConnectionClosedMsg = "Jogador offline:";
  static const String hostConnectionClosedMsg = "Host offline (Cliente):";

  PeerConnectionService({
    required this.gameProvider,
    required this.peer,
    this.myPeerId = '',
    required this.isServer,
  });

  /// Método abstrato para enviar dados
  void send(EventDTO event);

  /// Método abstrato para fechar conexões ativas
  void closeConnection();

  /// Método abstrato para destruir a instância atual do peer
  void destroy();

  /// Lógica Determinística para Eleição de um Novo Host
  /// 
  /// Pode ser invocada tanto pelo Cliente (ao perder a conexão com o host)
  /// quanto pelo Host (caso precise forçar re-eleição).
  void reconnectToLastHost() {
    final gameModel = gameProvider.gameModelDTO;

    if (gameModel == null) {
      log("Nenhum dado de jogo disponível. Assumindo Host.");
      gameProvider.switchToHostRole(myPeerId);
      return;
    }

    try {
      // 1. Marca os hosts anteriores como offline/não-host
      for (var player in gameModel.othersPlayers.values) {
        if (player.isHost) {
          player.isHost = false;
          player.isOnline = false;
        }
      }

      final activePlayers = gameModel.othersPlayers.values.toList();

      if (activePlayers.isEmpty) {
        log("Nenhum outro jogador restante na mesa. Assumindo Host.");
        gameProvider.switchToHostRole(myPeerId);
        return;
      }

      // 2. Adiciona o próprio jogador à lista de elegíveis para a eleição unânime
      activePlayers.add(gameModel.player);

      // 3. ORDENAÇÃO DETERMINÍSTICA: O menor ID alfabético ganha por consenso
      activePlayers.sort((a, b) => a.id.compareTo(b.id));

      // 4. O primeiro da lista ordenada é o novo líder unânime da mesa
      final newHostPlayer = activePlayers.first;

      log("Eleição concluída. Novo Host eleito por consenso: ${newHostPlayer.id}");

      // 5. ATUALIZAÇÃO DA VARIÁVEL isHost EM TODOS OS JOGADORES DO MODELO
      gameModel.player.isHost = (gameModel.player.id == newHostPlayer.id);
      for (var player in gameModel.othersPlayers.values) {
        player.isHost = (player.id == newHostPlayer.id);
      }

      // 6. Transição de Papel de Rede (Host ou Cliente)
      if (newHostPlayer.id == myPeerId) {
        log("Eu fui eleito o novo Host da mesa. Alternando para modo Host...");
        gameProvider.switchToHostRole(myPeerId);
      } else {
        log("Tentando se conectar automaticamente ao novo Host eleito: ${newHostPlayer.id}");
        
        // Dá tempo suficiente para o novo host eleito inicializar o servidor PeerJS
        Future.delayed(const Duration(seconds: 2), () {
          gameProvider.switchToClientRole(
            myPeerId: myPeerId, 
            hostPeerId: newHostPlayer.id,
          );
        });
      }
    } catch (e) {
      log("Falha crítica no processo de eleição de Host: ", error: e);
      gameProvider.switchToHostRole(myPeerId);
    }
  }

  /// Verifica se há conectividade de hardware local
  Future<bool> hasInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  /// Utilitário para extrair ID base
  String? extractBaseIdentifier(String peerId) {
    final parts = peerId.split('-');
    return parts.length >= 2 ? '${parts[0]}-${parts[1]}' : null;
  }
}