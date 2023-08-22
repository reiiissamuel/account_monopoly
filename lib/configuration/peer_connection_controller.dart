import 'dart:io';

import 'package:account_monopoly/dto/event_dto.dart';
import 'package:account_monopoly/enums/enums.dart';
import 'package:account_monopoly/model/game_model.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:peerdart/peerdart.dart';

import '../utils/string_utils.dart';

class PeerConnectionController {
  String myPeerId;
  Peer peer;
  late DataConnection connWithServer;
  bool isConnected = false;
  bool isServer = false;
  GameModelController gameModelController;
  List<String> candidatesPeersId = List<String>.empty();

  List<DataConnection> serverActiveConnections = List<DataConnection>.empty();

  PeerConnectionController({required this.gameModelController, required this.peer, required this.myPeerId});

  openForConnectionsAsServer(){
    peer.on("open").listen((id) {});

    peer.on("close").listen((id) {
      isConnected = false;
    });

    peer.on<DataConnection>("connection").listen((event) {
      isServer = true;
      serverActiveConnections.add(event);

      event.on("data").listen((data) {
        gameModelController.processComingEvent(EventDTO.fromMap(data));
      });

      event.on("close").listen((event) {
        //serverActiveConnections.removeWhere((c) => c.open == false);
        //
      });

      isConnected = true;
    });
  }

  connectToServer(String peerSourceId){
    connWithServer = peer.connect(peerSourceId);
    connWithServer.on("open").listen((event) {
      isConnected = true;});

    connWithServer.on("close").listen((event) {
      isConnected = false;
    });

    connWithServer.on("data").listen((data) {
      gameModelController.processComingEvent(EventDTO.fromMap(data));
    });
  }

  _hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      closeConnection();
    }
  }
   checkConnectivity() async {
    if(await _hasInternet()){
      if(isServer){
        late DataConnection closedNode;
        closedNode = serverActiveConnections.firstWhere((c) => !c.open);
        if(closedNode.open != null){
          serverActiveConnections.removeWhere((c) => c.connectionId == closedNode.connectionId);
          send(
              EventDTO(eventId: StringUtils().generateUUID(size: 8),
                  type: LogMsgType.LOST_CONNECTION,
                  sourcePlayer: gameModelController.gameModelDTO!.players.firstWhere((p) => p.peerId == closedNode.peer),
                  playerAndHost: false));
        }
      } else {
        if (!connWithServer.open){
          String nextPeerId = _getNextServerCandidatePeerId();
          if(myPeerId == nextPeerId){
            openForConnectionsAsServer();
          }else{
            connectToServer(nextPeerId);
          }
        }
      }
    } else {
      closeConnection();
    }
  }

  String _getNextServerCandidatePeerId(){
    for (var i = 0; i < candidatesPeersId.length; i++) {
      if(connWithServer.peer == candidatesPeersId[i]){
        if(i == candidatesPeersId.length - 1){
          return candidatesPeersId[0];
        }
        return candidatesPeersId[i + 1];
      }
    }
    throw Exception("Não existem peer id na lista");
  }

  closeConnection(){
    serverActiveConnections = [];
    //candidatesPeersId = [];
    isConnected = false;
    connWithServer == null;
    isServer = false;
    peer.dispose();
  }

  /*reconnectToDestination(String nextPeerSourceId){
    serverActiveConnections = [];
    peer = Peer(id: myPeerId);
    connectToServer(nextPeerSourceId);
  }*/

  send(EventDTO event){
    if(isServer){
      for (var e in serverActiveConnections) {
        e.send(event.toMap());
      }
    } else{
      connWithServer.send(event.toMap());
    }
  }

}