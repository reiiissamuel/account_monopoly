
import 'package:account_monopoly/configuration/peer_connection_controller.dart';
import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/game_model_dto.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/screens/my_games_screen.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/exception/game_already_in_player_list_exception.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';

import 'package:account_monopoly/domain/enums/event_type.dart';

class GameProvider extends ChangeNotifier {
  late UserProvider userModelController;
  //late Player player;
  PeerConnectionController? peerConnectionController;
  GameModelDTO? gameModelDTO;
  bool isLoading = false;
  List<EventDTO> events = [];
  EventDTO? lastEventReceived;
  String ?any;


  GameProvider();

  Ledger get ledger => gameModelDTO!.ledger;
  Player get currentPlayer => gameModelDTO!.player;
  bool get forbiddenAction => ledger.isBlacklisted(currentPlayer.id);

  void notifyChanges(bool isLoading) {
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

    double? value = event.value;
    Player ?destinationPlayer = event.destinationPlayer;
    Player sourceplayer = event.sourcePlayer;

    if(sourceplayer.id == currentPlayer.id) return;
    gameModelDTO!.updateOtherPlayers(sourceplayer); //atualiza o estado do jogador que enviou o evento
    switch (event.type) {
      case EventType.transfer:
        if(destinationPlayer!.id == currentPlayer.id){ 
          currentPlayer.roundBalance.transferIn += value!;
          currentPlayer.receiveCredit(value, ledger.incomeTaxRate);
        } else {
          gameModelDTO!.updateOtherPlayers(destinationPlayer);
        }
        break;
      case EventType.build && EventType.buyFromIPO:
        ledger.properties[event.property!.id] = event.property!;
        break;
      case EventType.setTradeOffer:
        ledger.setTradeOffer(event.tradeOffer!);
        break;
      case EventType.buyFromTrade:
        if(destinationPlayer!.id == currentPlayer.id){
          currentPlayer.downgradePortfolio(event.tradeOffer!.propertyId, event.tradeOffer!.sharesAmount);
        } else {
          gameModelDTO!.updateOtherPlayers(destinationPlayer);
        }
        ledger.finishTradeOffer(event.tradeOffer!.offerId, event.tradeOffer!.propertyId);
        break;
      case EventType.mortgageForeclosure:
        ledger.bankPortfolio[event.property!.id] = ShareHolder(
          playerId: sourceplayer.id,
          propertyId: event.property!.id,
          sharesOwned: value!.toInt(),
          investmentValue: 0);
        break;
      case EventType.bankruptcy:
        if (event.sourcePlayer.isHost) {
          //todo vericar: caso seja proximo na lista de conexão, abre host, caso contrario tenta se conectar com proximo horst
        }
        break;
      case EventType.iwon:
        gameModelDTO!.winner = sourceplayer;
        break;
      case EventType.joinTable:
        gameModelDTO!.updateOtherPlayers(sourceplayer);
        break;
      case EventType.serverHandShake:
        _dealHostHandShakeEvent(event);
        break;
      case EventType.lostConnection:
        gameModelDTO!.othersPlayers.remove(sourceplayer.id);
      default:
        break;
    }
    gameModelDTO!.logs.add(event.getEventLog(currentPlayer));
  }

  void processRoundEnding(){
    eventComposer(type: EventType.roundBonus, value: gameModelDTO!.roundBonus);
    eventComposer(type: EventType.closeRound);

    final foreclosusureLoans = gameModelDTO!.ledger.managePlayerLoans(gameModelDTO!.player);
    if(foreclosusureLoans.isNotEmpty){
      for(var loan in foreclosusureLoans){
        if(loan.type == LoanType.bankLoan){
          eventComposer(type: EventType.loanForeclosure, value: loan.totalDue);
        }
        else if(loan.type == LoanType.mortgage){
          eventComposer(type: EventType.mortgageForeclosure, property: ledger.properties[loan.collateralId]);
        }
      }
    }
    if (ledger.badCreditList.containsKey(currentPlayer.id)){
      eventComposer(type: EventType.bankBlacklisted);
    }
  }

  Future<void> eventComposer({required EventType type, Player? destinationPlayer, Player? sourcePlayer, double? value,
   Property ?property, double? buildingRentIncrease, bool? buildingPlayerPayment, TradeOffer? tradeOffer, String? loanId}) async {
    notifyChanges(true);

    EventDTO event = EventDTO(
        type: type,
        destinationPlayer: destinationPlayer,
        sourcePlayer: sourcePlayer ?? currentPlayer,
        tradeOffer: tradeOffer,
        property: property,
        value: value);

    switch (event.type) {
      case EventType.closeTurn:
        
        break;
      case EventType.payTax:
        event.value = currentPlayer.incomeTax;
        ledger.processIncomeTaxPayment(currentPlayer);
        break;
      case EventType.receiveTax:
        event.value = ledger.processTaxRefund(currentPlayer);
        break;
      case EventType.roundBonus:
        ledger.processRoundBonus(currentPlayer);
        break;
      case EventType.payBank:
        currentPlayer.payDebit(value!);
        currentPlayer.roundBalance.otherOut += value;
        break;
      case EventType.receiveFromBank:
        currentPlayer.receiveCredit(value!, ledger.incomeTaxRate);
        currentPlayer.roundBalance.otherIn += value;
        break;
      case EventType.transfer:
        currentPlayer.payDebit(value!);
        currentPlayer.roundBalance.transferOut += value;
        destinationPlayer!.receiveCredit(value, ledger.incomeTaxRate);
        destinationPlayer.roundBalance.transferIn += value;
        break;
      case EventType.loan:
        currentPlayer.receiveCredit(value!, 0);
        gameModelDTO!.player.roundBalance.otherIn += value;
        break;
      case EventType.loanPayment:
        ledger.processLoanPayment(currentPlayer, loanId!, event.value!);
        break;
      case EventType.buyFromIPO:
        ledger.buyFromIPO(currentPlayer, property!.id, value!.toInt());
        ledger.checkForMajorOwner(currentPlayer, property.id);
        break;
      case EventType.setTradeOffer:
        ledger.setTradeOffer(tradeOffer!);
        break;
      case EventType.buyFromTrade:
        ledger.buyFromTrade(currentPlayer, tradeOffer!, destinationPlayer!);
        ledger.checkForMajorOwner(currentPlayer, tradeOffer.propertyId);
      case EventType.closeRound:
        gameModelDTO!.ledger.calculateDividendsToPay(currentPlayer);
        event.value = currentPlayer.roundBalance.dividendsIn;
        currentPlayer.financialReport.addRoundBalance(gameModelDTO!.currentRound, currentPlayer.roundBalance.copyAndReset());
        gameModelDTO!.currentRound += 1;
        break;
      case EventType.build:
        ledger.processBuildingPurchase(currentPlayer, property!, value!, buildingRentIncrease!, buildingPlayerPayment!);
        break;
      case EventType.bankruptcy:
        //
        break;
      case EventType.iwon:
        gameModelDTO!.winner = currentPlayer;
        break;
      case EventType.serverHandShake:
        currentPlayer.isHost = true;
         //int i = gameModelDTO!.othersPlayers.indexWhere((p) => p.id == gameModelDTO!.player.id);
        //i >= 0 ? gameModelDTO!.othersPlayers[i] = gameModelDTO!.player : gameModelDTO!.othersPlayers.add(gameModelDTO!.player);
        event.gameData = gameModelDTO!.toInitialTemplate();
        break;
      case EventType.lostConnection:
        //gameModelDTO!.othersPlayers.remove(currentPlayer.id);
        //todo salvar jogo e sair;
        break;
      default:
        break;
    }
    _sendEvent(event);
    gameModelDTO!.logs.add(event.getEventLog(currentPlayer));
    await _updateUserModel();
    notifyChanges(false);
  }

  void _sendEvent(EventDTO event) {
    peerConnectionController!.send(event);
  }

  void createNewGame({required GameModelDTO game, required Function onFail, required Function onSuccess}) async {
    isLoading = true;
    notifyListeners();
    String usermodelname = userModelController.user!.username;
    int usermodelId = userModelController.user!.id!;
    String generatedGameId = StringUtils.generateUUID(size: 8);

    gameModelDTO = game;
    gameModelDTO!.player = Player.newGamePlayer(
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

    gameModelDTO!.updateOtherPlayers(event.sourcePlayer); //add hostplayer as otherplayer
    gameModelDTO!.player = Player.ofDefinedId(
        id: peerConnectionController!.myPeerId,
        username: userModelController.user!.username
    );
    _sendEvent(EventDTO(
        type: EventType.joinTable,
        destinationPlayer: event.sourcePlayer,
        sourcePlayer: gameModelDTO!.player,
        value: 0));
    isLoading = false;
    notifyListeners();
  }
}
