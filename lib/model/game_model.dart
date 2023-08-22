import 'dart:async';
import 'dart:io';
import 'package:account_monopoly/configuration/peer_connection_controller.dart';
import 'package:account_monopoly/dto/player.dart';
import 'package:account_monopoly/model/user_model.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peerdart/peerdart.dart';
import 'package:scoped_model/scoped_model.dart';

import '../dto/account.dart';
import '../dto/auction.dart';
import '../dto/balance.dart';
import '../dto/chance.dart';
import '../dto/event_dto.dart';
import '../dto/hipoteca.dart';
import '../enums/enums.dart';

class GameModelController extends Model {
  UserModelController userModelController;
  PeerConnectionController? peerConnectionController;
  AuctionController auctionController = AuctionController();
  GameModelDTO? gameModelDTO;
  bool isLoading = false;
  bool isThereAuction = false;
  List<EventDTO> events = [];
  EventDTO? lastEventReceived;

  bool youWon = false;

  GameModelController({required this.userModelController}) {
    /*if(userModelController.isLoggedIn()){

    }*/
  }

  static GameModelController of(BuildContext context) =>
      ScopedModel.of<GameModelController>(context);

  void notify() {
    notifyListeners();
  }

  processComingEvent(EventDTO event) {
    isLoading = true;
    notifyListeners();
    if(events.isEmpty || event.eventId != lastEventReceived?.eventId){
      lastEventReceived = event;
      events.add(event);
      _eventEntranceManager(event);
    }

    isLoading = false;
    notifyListeners();
  }

  /*void _loadStreamSubscription() {
    _eventListStreamController.stream.listen((event) {
      _eventEntranceManager(event);
    });
  }*/

  void _eventEntranceManager(EventDTO event) {
    int? value = event.value;
    Player sourceplayer = event.sourcePlayer;
    switch (event.type) {
      case LogMsgType.TRANSFER:
        _updateBalance(value!);
        gameModelDTO!.players
            .firstWhere((p) => p.peerId == sourceplayer.peerId)
            .receivedFrom += value;
        break;
      case LogMsgType.AUCTION_START:
        isThereAuction = true;
        Auction? auction = event.auction;
        if (auction != null) {
          auctionController.setNewAuction(auction);
        }
        break;
      case LogMsgType.AUCTION_END:
        isThereAuction = false;
        auctionController.endAuction();
        break;
      case LogMsgType.AUCTION_PAY:
        auctionController.payMinimmun(sourceplayer.username);
        break;
      case LogMsgType.AUCTION_RAISE:
        auctionController.raise(value!, sourceplayer.username);
        break;
      case LogMsgType.JOIN_TABLE:
        gameModelDTO!.players.add(sourceplayer);
        peerConnectionController!.candidatesPeersId.add(sourceplayer.peerId);
        break;
      case LogMsgType.SERVER_HAND_SHAKE:
        gameModelDTO = event.gameData;
        for (var p in gameModelDTO!.players) {
          peerConnectionController!.candidatesPeersId.add(p.peerId);
        }
        break;
      case LogMsgType.BANKRUPTCY:
        if (event.playerAndHost) {
          //todo vericar: caso seja proximo na lista de conexão, abre host, caso contrario tenta se conectar com proximo horst
        }
        gameModelDTO!.players.removeWhere((p) =>
        p.peerId == sourceplayer.peerId);
        break;
      default:
        break;
    }
    _logComposer(event);
  }

  void eventComposer({required LogMsgType type, required Player destinationPlayer, required int value}) {
    isLoading = true;
    notifyListeners();

    Player sourcePlayer = gameModelDTO!.players.first;
    EventDTO event =
    EventDTO(
        ///generate event id hash
        eventId: StringUtils().generateUUID(size: 8) + userModelController.user!.username,
        type: type,
        destinationPlayer: destinationPlayer,
        sourcePlayer: sourcePlayer,
        value: value,
        playerAndHost: peerConnectionController!.isServer);

    switch (event.type) {
      case LogMsgType.TRANSFER:
        gameModelDTO!.account.transferOut += value;
        gameModelDTO!.players
            .firstWhere((p) => p.peerId == destinationPlayer.peerId)
            .payedTo += value;
        break;
      case LogMsgType.BUY:
        gameModelDTO!.account.qtdPurchases += value;
        break;
      case LogMsgType.PAY_BANK:
        gameModelDTO!.account.otherPaymentsOut += value;
        _updateBalance(-value);
        break;
      case LogMsgType.RECEIVE_FROM_BANK:
        _updateBalance(value);
        break;
      case LogMsgType.BUILD_HOUSE:
        gameModelDTO!.account.qtdHome += value;
        break;
      case LogMsgType.BUILD_HOTEL:
        gameModelDTO!.account.qtdHotel += value;
        break;
      case LogMsgType.HIPOTECA:
        gameModelDTO!.account.hipotecasIn += value;
        _updateBalance(value);
        break;
      case LogMsgType.LOAN:
        gameModelDTO!.account.loanIn += value;
        _updateBalance(value);
        break;
      case LogMsgType.AUCTION_START:
        isThereAuction = true;
        Auction? auction = event.auction;
        if (auction != null) {
          auctionController.setNewAuction(auction);
        }
        break;
      case LogMsgType.AUCTION_END:
        isThereAuction = false;
        auctionController.endAuction();
        break;
      case LogMsgType.AUCTION_PAY:
        auctionController.payMinimmun(sourcePlayer.username);
        break;
      case LogMsgType.AUCTION_RAISE:
        auctionController.raise(value, sourcePlayer.username);
        break;
      case LogMsgType.BANKRUPTCY:
        if (gameModelDTO!.players.isNotEmpty) {
          gameModelDTO!.youBankrupt = true;
        }
        break;
      case LogMsgType.IWON:
        gameModelDTO!.youWon = true;
        break;
      default:
        break;
    }
    _sendEvent(event);
    _logComposer(event);
    isLoading = false;
    notifyListeners();
  }

  _sendEvent(EventDTO event) {
    isLoading = true;
    notifyListeners();

    peerConnectionController!.checkConnectivity();
    peerConnectionController!.send(event);
    processComingEvent(event);

    isLoading = false;
    notifyListeners();
  }

  _logComposer(EventDTO event) {
    if (event.type.messageScope != null) {
      gameModelDTO!.logs.add(
          event.type.messageScope
          !.replaceAll('{SOURCE}', event.sourcePlayer.username)
              .replaceAll('{VALUE}', event.value.toString())
              .replaceAll('{DEST}', event.destinationPlayer!.username)
      );
    }
  }

  void createNewGame({required GameModelDTO gameData ,required Function onFail, required Function onSuccess}) async {
    isLoading = true;
    notifyListeners();
    userModelController.user!.games.add(gameData);
    gameModelDTO = gameData;
    peerConnectionController = PeerConnectionController(
        gameModelController: this, peer: Peer(id: gameModelDTO!.players[0].peerId), myPeerId: gameModelDTO!.players[0].peerId);
    userModelController.updateUser().then((value) => {
        onSuccess()
    }).catchError((e) => {
      onFail("Algo deu errado!")
    });
    isLoading = false;
    notifyListeners();
  }

  ///essa requisição será respondida com um EventDTO do tipo JOIN_TABLE
  void enterNewGameByIdRequest(
      {required String peerId, required String gameCode, required Function onFail, required Function onSuccess}) async {
    userModelController.isLoading = true;
    userModelController.notifyListeners();
    try{
      peerConnectionController!.connectToServer(peerId);
      _sendEvent(EventDTO(
          eventId: StringUtils().generateUUID(size: 8) + userModelController.user!.username,
          type: LogMsgType.JOIN_TABLE,
          destinationPlayer: null,
          sourcePlayer: Player(peerId: peerId, username: userModelController.user!.username, receivedFrom: 0, payedTo: 0),
          value: 0,
          playerAndHost: peerConnectionController!.isServer));
      onSuccess;
    } catch (e){
      userModelController.isLoading = false;
      userModelController.notifyListeners();
      onFail;
    }
  }

  void getGameById({required String peerId, required Function onFail, required Function onSuccess}) async {
    isLoading = true;
    notifyListeners();
    DocumentSnapshot docGame = await db.collection("games")
        .document(gameCode)
        .get();
    if (docGame.data == null) {
      onFail('Jogo não existe ou pode estar corrompido!');
      isLoading = false;
      notifyListeners();
    } else {
      this.gameCode = gameCode;
      gameData = docGame.data;
      currentGameBalance = docGame.data["initialBalance"];
      _loadGamePlayers(); // ver a possibilidade de colocar esse metodo com retorno future null
      await db.collection("games").document(gameCode).updateData(
          {"log": user.userData["nick"] + " voltou para o jogo!"});
     // _loadStreamSubscription();

      isLoading = false;
      notifyListeners();
      onSuccess();
    }
  }

  void _loadGamePlayers() async {
    QuerySnapshot query = await db.collection("games")
        .document(gameCode)
        .collection("players")
        .getDocuments();
    if (query.documents.isNotEmpty) {
      players =
          query.documents.map((doc) => GamePlayer.fromDocument(doc)).toList();
      players.removeWhere((player) => player.playerId == user.firebaseUser.uid);
    } //se tirando da lista
    //notifyListeners();
  }

  //in game methods
  bool hasRoundsAccount(int round) {
    for (var account in gameModelDTO!.balance.accounts) {
      if (account.round == round) {
        return true;
      }
    }
    return false;
  }

  void exitGame() {
    isLoading = true;
    notifyListeners();

    logs = [];
    players = [];
    gameData = Map();
    gameCode = null;
    currentGameBalance = null;
    account = Account();
    balance = Balance();
    hipotecas = [];

    isLoading = false;
    notifyListeners();
  }

  bool hasEnoughBalance(int value) {
    if (value <= gameModelDTO!.currentGameBalance) {
      return true;
    }
    return false;
  }

  _updateBalance(int value) {
    gameModelDTO!.currentGameBalance += value;
    notifyListeners();
  }
}

class GameModelDTO{
  //String? gameCode; //TODO implementar senha
  int currentGameBalance = 0;
  int initalGameBalance = 0;
  int limitPlayer = 0;
  int faturaTax = 0;
  int loanTax = 0;
  int roundBonus = 0;
  Account account = Account.empty();
  Balance balance = Balance.empty();
  List<Player> players = List<Player>.empty();
  List<Hipoteca> hipotecas = [];
  List<String> logs = [];
  //List<Investment> investments= List<Investment>();
  List<Event> benefits = [];

  bool youWon = false;
  bool youBankrupt = false;

  GameModelDTO.empty();
  GameModelDTO({required int initalGameBalance, required int currentGameBalance, required this.roundBonus, required this.loanTax, required this.faturaTax, required this.limitPlayer, required this.players});
  GameModelDTO.initAllFields({required int initalGameBalance, required int currentGameBalance, required Account account, required Balance balance, required List<Player> players, required List<Hipoteca> hipotecas, required List<String> logs, required List<Event> benefits, required int roundBonus});
  Map<String, dynamic> toMap() {
    return {
      //'gameCode': gameCode,
      'currentGameBalance': currentGameBalance,
      'account': account.toMap(),
      'balance': balance.toMap(),
      'players': players.map((player) => player.toMap()).toList(),
      'hipotecas': hipotecas.map((hipoteca) => hipoteca.toMap()).toList(),
      'logs': logs,
      'benefits': benefits.map((benefits) => benefits.toMap()).toList(),
      'initalGameBalance': initalGameBalance
    };
  }

  factory GameModelDTO.fromMap(Map<String, dynamic> map) {
    return GameModelDTO.initAllFields(
        //gameCode: map['gameCode'] as String,
        currentGameBalance: map['currentGameBalance'] as int,
        account: Account.fromMap(map['account']),
        balance: Balance.fromMap(map['balance']),
        players: (map['players'] as List<dynamic>).map((p) => Player.fromMap(p as Map<String, dynamic>)).toList(),
        hipotecas: (map['hipotecas'] as List<dynamic>).map((h) => Hipoteca.fromMap(h as Map<String, dynamic>)).toList(),
        logs: (map['logs'] as List<dynamic>).cast<String>(),
        benefits: (map['benefits'] as List<dynamic>).map((b) => Event.fromMap(b as Map<String, dynamic>)).toList(),
        roundBonus:  map['roundBonus'] as int,
        initalGameBalance: map['initalGameBalance'] as int
    );
  }
}