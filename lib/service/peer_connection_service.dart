import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/provider/game_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:peer_rtc/peer_rtc.dart'; // <--- Mudança aqui
import 'dart:developer';

abstract class PeerConnectionService {
  String myPeerId;
  Peer peer;
  bool isConnected = false;
  bool isServer;
  GameProvider gameProvider;

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

  void send(EventDTO event);
  void closeConnection();
  void destroy();

  // Toda a lógica determinística de reconnectToLastHost() continua exatamente igual!
  void reconnectToLastHost() {
    // ... (mantém todo o código de eleição e ordenação por ID que você já tem)
  }

  Future<bool> hasInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }

  String? extractBaseIdentifier(String peerId) {
    final parts = peerId.split('-');
    return parts.length >= 2 ? '${parts[0]}-${parts[1]}' : null;
  }
}