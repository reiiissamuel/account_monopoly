
import 'package:account_monopoly/configuration/peer_connection_controller.dart';
import 'package:account_monopoly/domain/enums/installment_type.dart';
import 'package:account_monopoly/domain/model/game_model_dto.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/my_games_screen.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/exception/game_already_in_player_list_exception.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';

import 'package:account_monopoly/domain/model/auction.dart';
import 'package:account_monopoly/domain/event_dto.dart';
import 'package:account_monopoly/domain/enums/log_msg_type.dart';

class GameProvider extends ChangeNotifier {
  late UserProvider userModelController;
  //late Player player;
  PeerConnectionController? peerConnectionController;
  GameModelDTO? gameModelDTO;
  bool isLoading = false;
  bool isThereAuction = false;
  List<EventDTO> events = [];
  EventDTO? lastEventReceived;
  bool youWon = false;
  String ?any;


  GameProvider();

  //static GameModelController of(BuildContext context) =>
  //    ScopedModel.of<GameModelController>(context);

  void notifyChanges(isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }

  void processComingEvent(EventDTO event) {
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

  void _eventEntranceManager(EventDTO event) {
    int? value = event.value;
    Player sourceplayer = event.sourcePlayer;
    Player ?destinationPlayer = event.destinationPlayer;
    switch (event.type) {
      case LogMsgType.TRANSFER:
        if(destinationPlayer != null || destinationPlayer!.id == userModelController.user!.id.toString()) {
          _updateBalance(value!);
        }
        gameModelDTO!.othersPlayers
            .firstWhere((p) => p.id == sourceplayer.id)
            .receivedFrom += value!;
        break;
      case LogMsgType.AUCTION_START:
        isThereAuction = true;
        event.auction!.whichPlayersIdStillIn.add(Map.of({gameModelDTO!.player.id : true}));
        gameModelDTO!.auctions.add(event.auction!);
        break;
      case LogMsgType.AUCTION_END:
        isThereAuction = false;
        gameModelDTO!.auctions.last = event.auction!;
        if(gameModelDTO!.auctions.last.auctionCaller == gameModelDTO!.player.username){
          _updateBalance(gameModelDTO!.auctions.last.endValue);
        }
        gameModelDTO!.player.mortgages.removeWhere((m) => m.id == gameModelDTO!.auctions.last.mortgageId);
        break;
      case (LogMsgType.AUCTION_RAISE || LogMsgType.AUCTION_PAY):
        gameModelDTO!.auctions.last = event.auction!;
        break;
      case LogMsgType.JOIN_TABLE:
        gameModelDTO!.othersPlayers.add(sourceplayer);
        break;
      case LogMsgType.SERVER_HAND_SHAKE:
        _dealHostHandShakeEvent(event);
        break;
      case LogMsgType.BANKRUPTCY:
        if (event.sourcePlayer.isHost) {
          //todo vericar: caso seja proximo na lista de conexão, abre host, caso contrario tenta se conectar com proximo horst
        }
        gameModelDTO!.othersPlayers.removeWhere((p) =>
        p.id == sourceplayer.id);
        break;
      case LogMsgType.LOST_CONNECTION:
        gameModelDTO!.othersPlayers.removeWhere((p) =>
        p.id == sourceplayer.id);
      default:
        break;
    }
    _logComposer(event);
  }

  Future<void> eventComposer({required LogMsgType type, Player ?destinationPlayer, int ?value,
    Player ?sourcePlayer, Auction ?auction, int ?installments}) async {
    notifyChanges(true);

    EventDTO event =
    EventDTO(
        type: type,
        destinationPlayer: destinationPlayer,
        sourcePlayer: sourcePlayer ?? gameModelDTO!.player,
        value: value);

    switch (event.type) {
      case LogMsgType.CLOSE_TURN:
        event.value = -(gameModelDTO!.player.roundBalance.getTotal());
        _proccessCloseTurn(installments);
        _updateMortgageCountdown();
        break;
      case LogMsgType.CURRENT_ACCOUNT_UPDATE_UP:
        event.value = 200000;
        gameModelDTO!.player.roundBalance.restituicao = 200000;
        break;
      case LogMsgType.CURRENT_ACCOUNT_UPDATE_DOWN:
        event.value = 200000;
        gameModelDTO!.player.roundBalance.ir = 200000;
        break;
      case LogMsgType.ROUND_BONUS:
        gameModelDTO!.player.roundBalance.bonus += gameModelDTO!.roundBonus;
        break;
      case LogMsgType.TRANSFER:
        gameModelDTO!.player.roundBalance.transferOut += value!;
        _updateBalance(-value);
        gameModelDTO!.othersPlayers
            .firstWhere((p) => p.id == destinationPlayer!.id)
            .payedTo += value;
        break;
      case LogMsgType.BUY:
        gameModelDTO!.player.roundBalance.qtdPurchases += value!;
        _updateBalance(-value);
        break;
      case LogMsgType.PAY_BANK:
        gameModelDTO!.player.roundBalance.otherPaymentsOut += value!;
        _updateBalance(-value);
        break;
      case LogMsgType.RECEIVE_FROM_BANK:
        _updateBalance(value!);
        break;
      case LogMsgType.BUILD_HOUSE:
        gameModelDTO!.player.roundBalance.qtdHome += value!;
        _updateBalance(-value);
        break;
      case LogMsgType.BUILD_HOTEL:
        gameModelDTO!.player.roundBalance.qtdHotel += value!;
        _updateBalance(-value);
        break;
      case LogMsgType.MORTGAGE:
        gameModelDTO!.player.roundBalance.mortgagesIn += value!;
        _updateBalance(value);
        break;
      case LogMsgType.LOAN:
        gameModelDTO!.player.roundBalance.loanIn += value!;
        _updateBalance(value);
        gameModelDTO!.player.financialReport.generateInstallments(
            tax: (installments! * gameModelDTO!.levelTax).floor(),
            type: InstallmentType.LOAN_INSTALLMENT,
            installments: installments,
            total: value);
        break;
      case LogMsgType.AUCTION_START:
        isThereAuction = true;
        event.auction = auction;
        event.value = auction!.startValue;
        event.auction!.whichPlayersIdStillIn.add(Map.of({gameModelDTO!.player.id : false}));
        gameModelDTO!.auctions.add(auction);
        break;
      case LogMsgType.AUCTION_END:
        isThereAuction = false;
        gameModelDTO!.auctions.last.setFinalValue();
        _updateBalance(-gameModelDTO!.auctions.last.endValue);
        gameModelDTO!.player.mortgages.removeWhere((m) => m.id == gameModelDTO!.auctions.last.mortgageId);
        break;
      case LogMsgType.AUCTION_LEAVE:
        isThereAuction = false;
        gameModelDTO!.auctions.last.whichPlayersIdStillIn.firstWhere((e) => e.containsKey([gameModelDTO!.player.id]))[gameModelDTO!.player.id] = false;
        event.auction = gameModelDTO!.auctions.last;
        break;
      case LogMsgType.AUCTION_PAY:
        gameModelDTO!.auctions.last.buyer = gameModelDTO!.player.username;
        gameModelDTO!.auctions.last.currentValue = gameModelDTO!.auctions.last.startValue;
        event.auction = gameModelDTO!.auctions.last;
        event.value = gameModelDTO!.auctions.last.startValue;
        break;
      case (LogMsgType.AUCTION_RAISE):
        gameModelDTO!.auctions.last.buyer = gameModelDTO!.player.username;
        gameModelDTO!.auctions.last.currentValue += value!;
        event.auction = gameModelDTO!.auctions.last;
        break;
      case LogMsgType.BANKRUPTCY:
        if (gameModelDTO!.othersPlayers.isNotEmpty) {
          gameModelDTO!.youBankrupt = true;
        }
        break;
      case LogMsgType.IWON:
        gameModelDTO!.youWon = true;
        break;
      case LogMsgType.SERVER_HAND_SHAKE:
        gameModelDTO!.player.isHost = true;
         //int i = gameModelDTO!.othersPlayers.indexWhere((p) => p.id == gameModelDTO!.player.id);
        //i >= 0 ? gameModelDTO!.othersPlayers[i] = gameModelDTO!.player : gameModelDTO!.othersPlayers.add(gameModelDTO!.player);
        event.gameData = gameModelDTO!.toInitialTemplate();
        break;
      case LogMsgType.LOST_CONNECTION:
        gameModelDTO!.othersPlayers.removeWhere((p) => p.id == event.sourcePlayer.id);
        break;
      default:
        break;
    }
    _sendEvent(event);
    _logComposer(event);
    await _updateUserModel();
    notifyChanges(false);
  }

  void _sendEvent(EventDTO event) {
    peerConnectionController!.send(event);
    //processComingEvent(event);
  }

  void _logComposer(EventDTO event) {
    if (event.type.messageScope != null) {
      gameModelDTO!.logs.add(
          event.type.messageScope
          !.replaceAll('{SOURCE}', event.sourcePlayer.username == gameModelDTO!.player.username ? 'Você' : event.sourcePlayer.username)
              .replaceAll('{VALUE}', StringUtils.currencyFormat(event.value.toString()))
              .replaceAll('{DEST}', event.destinationPlayer != null && event.destinationPlayer!.username == gameModelDTO!.player.username ? 'Você' : event.sourcePlayer.username)
      );
    }
  }

  void createNewGame({required GameModelDTO game, required Function onFail, required Function onSuccess}) async {
    isLoading = true;
    notifyListeners();
    String usermodelname = userModelController.user!.username;
    int usermodelId = userModelController.user!.id!;
    String generatedGameId = StringUtils.generateUUID(size: 8);

    gameModelDTO = game;
    gameModelDTO!.player = Player.of(
      id:  GameProvider._generatePlayerId(
          usermodelname: userModelController.user!.username,
          usermodelId: userModelController.user!.id,
          gameId: gameModelDTO!.id),
      currentCredit: gameModelDTO!.initalGameCredit,
      userModelId: usermodelId,
      gameId: generatedGameId,
      username: usermodelname,
      isHost: true
    );


    try{
      _createPeerConnectionController(peerId: gameModelDTO!.player.id);
      peerConnectionController!.openConnectionsAsHost();
      userModelController.user!.games.add(gameModelDTO!);
      await _updateUserModel();
    } catch (e) {
      onFail("Algo deu errado!");
    } finally{
      onSuccess();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getGameById({required GameModelDTO gameModelDTO,  required Function onFail, required Function onSuccess}) async {
    isLoading = true;
    notifyListeners();
    gameModelDTO.player.isHost = false;
    this.gameModelDTO = gameModelDTO;
    _createPeerConnectionController(peerId: this.gameModelDTO!.player.id);
    try {
      peerConnectionController!.reconnect();
    } on Exception catch(e) {
      onFail(e);
    }
    isLoading = false;
    notifyListeners();

  }

  void enterNewGameByIdRequest(
      {required String destinationPeerId, required BuildContext context, required Function onFail, required Function onSuccess}) async {
    isLoading = true;
    notifyListeners();

    String gameId = destinationPeerId.split("-").last;

    try{
      if(userModelController.checkHasGameById(gameId)){
        throw GameAlreadyInPlayerListException;
      }
      
      _createPeerConnectionController(
          peerId: GameProvider._generatePlayerId(
              usermodelname: userModelController.user!.username,
              usermodelId: userModelController.user!.id,
              gameId: gameId)
      );
      peerConnectionController!.connectToHost(destinationPeerId);
      onSuccess;
    } on GameAlreadyInPlayerListException catch(g) {
          onFail(g);
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyGamesScreen()));
    } catch (e){
      onFail("Algo de errado ao criar a conexão.");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _createPeerConnectionController({required String peerId}){
    Peer peer = Peer(id: peerId);
    peerConnectionController = PeerConnectionController(
        gameModelController: this, peer: peer, myPeerId: peerId);
  }

  Future<void> _updateUserModel() async {
    await userModelController.updateUser().catchError((e) => {
      throw e
    });
  }

  static String _generatePlayerId({required usermodelname, required usermodelId, required gameId}){
    return "$usermodelname-$usermodelId-${StringUtils.generateUUID(size: 5)}-$gameId";
  }

  void _dealHostHandShakeEvent(EventDTO event){
    if(gameModelDTO == null){
      gameModelDTO = event.gameData;
    } else {
      gameModelDTO!.othersPlayers.clear();
    }

    gameModelDTO!.othersPlayers.add(event.sourcePlayer); //add hostplayer as otherplayer
    gameModelDTO!.player = Player.ofDefinedId(
        id: peerConnectionController!.myPeerId,
        username: userModelController.user!.username
    );
    _sendEvent(EventDTO(
        type: LogMsgType.JOIN_TABLE,
        destinationPlayer: event.sourcePlayer,
        sourcePlayer: gameModelDTO!.player,
        value: 0));
    isLoading = false;
    notifyListeners();
  }

  //in game methods

  void _updateMortgageCountdown(){
    for(var mortgage in gameModelDTO!.player.mortgages){
      mortgage.deadline -= 1;
      if(mortgage.deadline <= 0){
        Auction auction = Auction(
            id: StringUtils.generateUUID(size: 7),
            auctionCaller: "BANK",
            propertyName: mortgage.name,
            startValue: mortgage.value + ((mortgage.deadline * 10) * mortgage.value / 100).floor(),
            endValue: 0,
            currentValue: 0,
            mortgageId: mortgage.id);
        eventComposer(type: LogMsgType.AUCTION_START, auction: auction);
        return;
      }
    }
  }

  void _proccessCloseTurn(int ?installments){
    if(installments != null){
      gameModelDTO!.player.financialReport.generateInstallments(
          tax: (installments * gameModelDTO!.levelTax).floor(),
          type: InstallmentType.ACCOUNT_INSTALLMENT,
          installments: installments,
          total: gameModelDTO!.player.roundBalance.getTotal());
      gameModelDTO!.player.roundBalance.isInInstallment = true;
    } else {
      _updateBalance(-(gameModelDTO!.player.roundBalance.getTotal()));
    }
    //gameModelDTO!.player.balance.closeRoundAccount(account: gameModelDTO!.account);
    gameModelDTO!.player.financialReport.setNextRoundBalance();
    gameModelDTO!.player.financialReport.round += 1;
    gameModelDTO!.player.roundBalance = gameModelDTO!.player.financialReport.balances[gameModelDTO!.player.financialReport.round];
  }

  bool hasEnoughBalance(int value) {
    if (value <= gameModelDTO!.player.currentCredit) {
      return true;
    }
    return false;
  }

  void _updateBalance(int value) {
    gameModelDTO!.player.currentCredit += value;
    notifyListeners();
  }

  bool hasAnyLoanRunning() {
    return gameModelDTO!.player.financialReport.balances
        .getRange(
        gameModelDTO!.player.financialReport.round, (gameModelDTO!.player.financialReport.balances.isNotEmpty ? gameModelDTO!.player.financialReport.balances.length : 0))
        .any((a) => a.loanInstallment > 0);
  }
}
