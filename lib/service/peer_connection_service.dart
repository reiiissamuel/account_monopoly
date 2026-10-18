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

  // --- TRAVA DE SEGURANÇA CONTRA ELEIÇÕES DUPLICADAS ---
  bool _isReconnecting = false;

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
  void reconnectToLastHost() {
    if (_isReconnecting) {
      log("Eleição de host já está em andamento. Ignorando chamada redundante.");
      return;
    }
    _isReconnecting = true;

    final gameModel = gameProvider.gameModelDTO;

    if (gameModel == null) {
      log("Nenhum dado de jogo disponível. Assumindo Host.");
      _isReconnecting = false;
      gameProvider.switchToHostRole(myPeerId);
      return;
    }

    try {
      for (var player in gameModel.othersPlayers.values) {
        if (player.isHost) {
          player.isHost = false;
          player.isOnline = false;
        }
      }

      gameModel.player.isOnline = true;

      final activePlayers = gameModel.othersPlayers.values
          .where((player) => player.isOnline)
          .toList();

      if (!activePlayers.any((p) => p.id == gameModel.player.id)) {
        activePlayers.add(gameModel.player);
      }

      if (activePlayers.isEmpty) {
        log("Nenhum outro jogador restante na mesa. Assumindo Host.");
        _isReconnecting = false;
        gameProvider.switchToHostRole(myPeerId);
        return;
      }

      activePlayers.sort((a, b) => a.id.compareTo(b.id));
      final newHostPlayer = activePlayers.first;

      log("Eleição concluída. Novo Host eleito por consenso: ${newHostPlayer.id}");

      gameModel.player.isHost = (gameModel.player.id == newHostPlayer.id);
      for (var player in gameModel.othersPlayers.values) {
        player.isHost = (player.id == newHostPlayer.id);
      }

      if (newHostPlayer.id == myPeerId) {
        log("Eu fui eleito o novo Host da mesa. Alternando para modo Host...");
        _isReconnecting = false; // --- Liberta a trava aqui ---
        gameProvider.switchToHostRole(myPeerId);
      } else {
        log("Tentando se conectar automaticamente ao novo Host eleito: ${newHostPlayer.id}");
        
        Future.delayed(const Duration(seconds: 2), () {
          _isReconnecting = false; // --- Liberta a trava antes de mudar de papel ---
          gameProvider.switchToClientRole(
            myPeerId: myPeerId, 
            hostPeerId: newHostPlayer.id,
          );
        });
      }
    } catch (e) {
      log("Falha crítica no processo de eleição de Host: ", error: e);
      _isReconnecting = false; // --- Liberta em caso de erro ---
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