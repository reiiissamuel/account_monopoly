import 'package:account_monopoly/dto/event_dto.dart';
import 'package:account_monopoly/dto/player.dart';
import 'package:account_monopoly/enums/log_msg_type.dart';
import 'package:account_monopoly/exception/peer_unavailable_exception.dart';
import 'package:account_monopoly/model/game_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:peerdart/peerdart.dart';
import 'dart:developer';

import '../utils/string_utils.dart';

class PeerConnectionController {
  String myPeerId;
  Peer peer;
  late DataConnection connWithServer;
  bool isConnected = false;
  bool isServer = false;
  GameModelController gameModelController;
  //Set<String> candidatesPeersId = <String>{};

  List<DataConnection> serverActiveConnections = List<DataConnection>.empty();

  static const String OPENED_CONNECTION_MSG = "Peer aberto para conexões.";
  static const String CONNECTION_RECEIVED_MSG = "Nova conexão recebida do peer:";
  static const String PEER_CONNECTION_CLOSED = "Jogador offline:";
  static const String HOST_CONNECTION_CLOSED = "Jogador e host offline:";
  PeerConnectionController({required this.gameModelController, required this.peer, required this.myPeerId});
  

  openConnectionsAsHost(){
    peer.on("open").listen((id) {
      isConnected = true;
      log(OPENED_CONNECTION_MSG);
    });

    peer.on("close").listen((id) {
      closeConnection();
    });

    peer.on<DataConnection>("connection").listen((event) {
      isServer = true;
      serverActiveConnections.add(event);

      event.on("open").listen((data) {
        log('$CONNECTION_RECEIVED_MSG $data');
        gameModelController.eventComposer(
            type: LogMsgType.SERVER_HAND_SHAKE,
            destinationPlayer: Player.ofDefinedId(username: "", id: data)
        );
      });

      event.on("data").listen((data) {
        gameModelController.processComingEvent(EventDTO.fromMap(data));
        send(data);
      });

      event.on("close").listen((event) {
        DataConnection closedNode = serverActiveConnections.firstWhere((c) => !c.open);
        serverActiveConnections.removeWhere((c) => c.connectionId == closedNode.peer);
        log('$PEER_CONNECTION_CLOSED $closedNode');
        gameModelController.eventComposer(type: LogMsgType.LOST_CONNECTION, sourcePlayer: gameModelController.gameModelDTO!.players.firstWhere((p) => p.id == closedNode.peer));
      });

      event.on('disconnected').listen((event) {
        print("Desconectado");
      });

      isConnected = true;
    });
  }

  connectToHost(String peerSourceId){
    connWithServer = peer.connect(peerSourceId);
    connWithServer.on("open").listen((event) {
      isConnected = true;});

    connWithServer.on("close").listen((event) {
      log(HOST_CONNECTION_CLOSED);
      closeConnection();
      late DataConnection closedNode;
      closedNode = serverActiveConnections.firstWhere((c) => !c.open);
      gameModelController.processComingEvent(
        EventDTO(
            type: LogMsgType.LOST_CONNECTION,
            sourcePlayer: gameModelController.gameModelDTO!.players.firstWhere((p) => p.id == closedNode.peer))
      );
      String nextPeerId = _getNextServerCandidatePeerId();
      peer = Peer(id: myPeerId);
      if(myPeerId == nextPeerId){
        openConnectionsAsHost();
      } else {
        connectToHost(nextPeerId);
      }
    });

    connWithServer.on("data").listen((data) {
      gameModelController.processComingEvent(EventDTO.fromMap(data));
    });

    connWithServer.on('disconnected').listen((event) {
      //todo tratar desonexão
      print("Desconectado");
    });

    connWithServer.on('peer-unavailable').listen((event) {
      throw PeerUnavailableException;
    });
  }

  Future<bool> _hasInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      closeConnection();
    }
    return isConnected;
  }
  
  String _getNextServerCandidatePeerId(){
    return gameModelController.gameModelDTO!.players.firstWhere((p) => !p.isHost).id;
  }

  closeConnection(){
    if(isServer){
      serverActiveConnections = [];
      isServer = false;
    } else {
      connWithServer.close();
    }

    peer.dispose();
    isConnected = false;
  }

  send(EventDTO event){
    if(isServer){
      for(DataConnection dataConnection in serverActiveConnections){
        if(dataConnection.peer != event.sourcePlayer.id){
          dataConnection.send(event.toMap());
        }
      }
    } else {
      connWithServer.send(event.toMap());
    }
  }

}