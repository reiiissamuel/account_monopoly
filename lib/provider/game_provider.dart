
import 'dart:developer';

import 'package:account_monopoly/configuration/peer_connection_controller.dart';
import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/game_model_dto.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/loan.dart';
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
  PeerConnectionController? peerConnectionController;
  GameModelDTO? gameModelDTO;
  bool isLoading = false;
  List<EventDTO> events = [];
  EventDTO? lastEventReceived;
  String? any;

  void reset(){
    gameModelDTO = null;
    isLoading = false;
    events = [];
    lastEventReceived = null;
  }
  GameProvider();

  Ledger get ledger => gameModelDTO!.ledger;
  Player get currentPlayer => gameModelDTO!.player;
  Map<String, Player> get otherPlayers => gameModelDTO!.othersPlayers;

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

    Player sourceplayer = event.sourcePlayer;
    if(event.type == EventType.serverHandShake) {
      _dealHostHandShakeEvent(event);
    } else {
      num? value = event.value;
      Player ?destinationPlayer = event.destinationPlayer;

      if(sourceplayer.id == currentPlayer.id) return;
      gameModelDTO!.updateOtherPlayers(sourceplayer); //atualiza o estado do jogador que enviou o evento
      switch (event.type) {
        case EventType.closeTurn:
          ledger.checkTradeOffersDeadline();
          break;
        case EventType.transfer:
          if(destinationPlayer!.id == currentPlayer.id){
            currentPlayer.roundBalance.transferIn += value!;
            currentPlayer.receiveCredit(value.toDouble(), ledger.incomeTaxRate);
          } else {
            gameModelDTO!.updateOtherPlayers(destinationPlayer);
          }
          break;
        case EventType.build || EventType.buyFromIPO || EventType.propertyUpdatePayout || EventType.payRent:
          ledger.properties[event.property!.id] = event.property!;
          break;
        case EventType.setTradeOffer:
          ledger.tradeOffers[event.tradeOffer!.offerId] = event.tradeOffer!;
          break;
        case EventType.buyFromTrade:
          if(destinationPlayer!.id == currentPlayer.id){
            currentPlayer.downgradePortfolio(event.tradeOffer!.propertyId, event.tradeOffer!.sharesAmount, event.tradeOffer!.totalAskingPrice);
          } else {
            gameModelDTO!.updateOtherPlayers(destinationPlayer);
          }
          ledger.finishTradeOffer(event.tradeOffer!.offerId);
          break;
        case EventType.mortgageForeclosure:
          ledger.bankPortfolio[event.property!.id] = ShareHolder(
              playerId: sourceplayer.id,
              propertyId: event.property!.id,
              sharesOwned: value!.toInt(),
              investmentValue: 0,
              saleCapitalGain: 0);
          break;
        case EventType.closeRound:
          if(event.referenceRound < ledger.lastPropertiesUpdateRound) return;
          ledger.updatePropertiesValuation(currentPlayer, event.referenceRound);
          event.value = currentPlayer.roundBalance.dividendsIn;
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
        case EventType.lostConnection:
          gameModelDTO!.othersPlayers.remove(sourceplayer.id);
        default:
          break;
      }
    }

    gameModelDTO!.logs.add(event.getEventLog(currentPlayer));
  }

  void processRoundEnding(){
    eventComposer(type: EventType.roundBonus, value: ledger.roundBonus);
    eventComposer(type: EventType.closeRound);

    List<Loan> foreclosureLoans = gameModelDTO!.ledger.managePlayerLoans(gameModelDTO!.player);
    if(foreclosureLoans.isNotEmpty){
      for(var loan in foreclosureLoans){
        if(loan.type == LoanType.bankLoan){
          eventComposer(type: EventType.loanForeclosure, value: loan.totalDue);
        }
        else if(loan.type == LoanType.mortgage){
          eventComposer(type: EventType.mortgageForeclosure, propertyId: loan.collateralId);
        }
      }
    }
    if (ledger.badCreditList.containsKey(currentPlayer.id)){
      eventComposer(type: EventType.bankBlacklisted);
    }
  }

  void eventComposer({required EventType type, Player? destinationPlayer, Player? sourcePlayer, num? value, int? markupUsage,
   String? propertyId, int? newBuildings, TradeOffer? tradeOffer, Loan? loan}) {
    try{
      notifyChanges(true);

      EventDTO event = EventDTO(
          referenceRound: gameModelDTO!.currentRound,
          type: type,
          destinationPlayer: destinationPlayer,
          sourcePlayer: sourcePlayer ?? currentPlayer,
          tradeOffer: tradeOffer,
        // property: property,
          value: value);

      switch (event.type) {
        case EventType.propertyUpdatePayout:
          event.property = ledger.updatePropertyPayout(propertyId!, value!.toDouble());
          break;
        case EventType.closeTurn:
          ledger.checkTradeOffersDeadline();
          break;
        case EventType.payRent:
          event.property = ledger.processRentPayment(currentPlayer, propertyId!, value!.toDouble());
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
          currentPlayer.payDebit(value!.toDouble());
          currentPlayer.roundBalance.otherOut += value;
          break;
        case EventType.receiveFromBank:
          currentPlayer.receiveCredit(value!.toDouble(), ledger.incomeTaxRate);
          currentPlayer.roundBalance.otherIn += value;
          break;
        case EventType.transfer:
          currentPlayer.payDebit(value!.toDouble());
          currentPlayer.roundBalance.transferOut += value;
          destinationPlayer!.receiveCredit(value.toDouble(), ledger.incomeTaxRate);
          destinationPlayer.roundBalance.transferIn += value;
          break;
        case EventType.loan:
          ledger.processLoanAcquisition(currentPlayer, loan!);
          break;
        case EventType.loanPayment:
          ledger.processLoanPayment(currentPlayer, loan!.id, value!.toDouble());
          break;
        case EventType.mortgageForeclosure:
          event.property = ledger.properties[propertyId];
          break;
        case EventType.buyFromIPO:
          event.property = ledger.buyFromIPO(currentPlayer, propertyId!, value!.toInt());
          ledger.checkForMajorOwner(currentPlayer, propertyId);
          break;
        case EventType.setTradeOffer:
          ledger.setTradeOffer(currentPlayer, tradeOffer!);
          break;
        case EventType.buyFromTrade:
          ledger.buyFromTrade(currentPlayer, tradeOffer!, destinationPlayer);
          ledger.checkForMajorOwner(currentPlayer, tradeOffer.propertyId);
          break;
        case EventType.closeRound:
          if(gameModelDTO!.currentRound > ledger.lastPropertiesUpdateRound){
            ledger.updatePropertiesValuation(currentPlayer, gameModelDTO!.currentRound);
            event.value = currentPlayer.roundBalance.dividendsIn;
            currentPlayer.financialReport.addRoundBalance(gameModelDTO!.currentRound, currentPlayer.roundBalance.copyAndReset());
            gameModelDTO!.currentRound += 1;
          } else{
            currentPlayer.financialReport.addRoundBalance(gameModelDTO!.currentRound, currentPlayer.roundBalance.copyAndReset());
            gameModelDTO!.currentRound += 1;
            return;
          }
          break;
        case EventType.build:
          event.property = ledger.processBuildingPurchase(currentPlayer, propertyId!, newBuildings!, value!.toDouble(), markupUsage!);
          break;
        case EventType.bankruptcy:
          //
          break;
        case EventType.iwon:
          gameModelDTO!.winner = currentPlayer;
          break;
        case EventType.serverHandShake:
          currentPlayer.isHost = true;
          gameModelDTO!.othersPlayers[gameModelDTO!.player.id] = gameModelDTO!.player;
          gameModelDTO!.othersPlayers[destinationPlayer!.id] = destinationPlayer;
          event.gameData = gameModelDTO;
          break;
        case EventType.lostConnection:
          gameModelDTO!.othersPlayers.remove(currentPlayer.id);
          //todo salvar jogo e sair;
          break;
        default:
          break;
      }
      _sendEvent(event);
      gameModelDTO!.logs.add(event.getEventLog(currentPlayer));
      _updateUserModel();
      notifyChanges(false);
    } on Exception{
      notifyChanges(false);
      rethrow;
    }
  }

  void _sendEvent(EventDTO event) {
    peerConnectionController!.send(event);
  }

  List<TradeOffer> getAllMarketListings() {
  final List<TradeOffer> listings = [];

  // -------------------------------------------------------------
  // A. IPO / FUNDO (Property.availableShares)
  // -------------------------------------------------------------
  for (var property in ledger.properties.values) {
    if (property.availableShares > 0) {
      listings.add(TradeOffer(
        offerId: property.id,
        propertyId: property.id,
        sellerPlayerId: ledger.bankId,
        sharesAmount: property.availableShares,
        askingPrice: property.sharePrice,
        source: OfferSource.fundIPO,
        currentMarketPrice: property.sharePrice,
        colorSignature: property.colorSignature,
        propertyName: property.name,
        turnsToEnd: 1
      ));
    }
  }

  // -------------------------------------------------------------
  // B. ATIVOS RECUPERADOS DO BANCO (Ledger.bankPortfolio)
  // -------------------------------------------------------------
  for (var entry in ledger.bankPortfolio.entries) {
    final propertyId = entry.key;
    final bankShare = entry.value;
    final property = ledger.properties[propertyId]!;
    
    if (bankShare.sharesOwned > 0) {
      listings.add(TradeOffer(
        offerId: propertyId,
        propertyId: propertyId,
        sellerPlayerId: ledger.bankId,
        sharesAmount: bankShare.sharesOwned,
        askingPrice: property.sharePrice - (property.sharePrice * 0.1),
        source: OfferSource.bankForeclosed,
        currentMarketPrice: property.sharePrice,
        colorSignature: property.colorSignature.withValues(alpha: 0.7), // Cor ligeiramente diferente
        propertyName: '${property.name} (Recup.)',
        turnsToEnd: 1
      ));
    }
  }

  // -------------------------------------------------------------
  // C. MERCADO SECUNDÁRIO (P2P - Ofertas de Jogadores)
  // -------------------------------------------------------------
  for (var offer in ledger.tradeOffers.values) {
    final property = ledger.properties[offer.propertyId];
    listings.add(TradeOffer(
      offerId: offer.offerId,
      propertyId: offer.propertyId,
      sellerPlayerId: offer.sellerPlayerId,
      sharesAmount: offer.sharesAmount,
      askingPrice: offer.askingPrice,
      turnsToEnd: offer.turnsToEnd,
      source: OfferSource.playerMarket,
      currentMarketPrice: property!.sharePrice,
      colorSignature: property.colorSignature,
      propertyName: '${property.name} (Venda P2P)',
    ));
  }
  
  return listings;
}

  void createNewGame({required GameModelDTO game}) async {
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
    gameModelDTO!.updateOtherPlayers(gameModelDTO!.player);
    try{
      _createPeerConnectionController(peerId: gameModelDTO!.player.id);
      peerConnectionController!.openConnectionsAsHost();
      userModelController.user!.games.add(gameModelDTO!);
      await _updateUserModel();
    } catch (e) {
      log("Erro na tentativa de criar um novo jogo no repositório: $e");
      rethrow;
    } finally{
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getGameById(GameModelDTO gameModelDTO) async {
    isLoading = true;
    notifyListeners();
    gameModelDTO.player.isHost = false;
    this.gameModelDTO = gameModelDTO;
    _createPeerConnectionController(peerId: this.gameModelDTO!.player.id);
    try {
      peerConnectionController!.reconnect();
    } on Exception catch(e) {
      log("Erro ao tentar carrega um jogo existente: $e");
      rethrow;
    }
    isLoading = false;
    notifyListeners();

  }

  void enterNewGameByIdRequest({required String destinationPeerId}) async {
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
    } catch (e){
      log("Erro: $e");
      rethrow;
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

    gameModelDTO!.player = Player.ofDefinedId(
        id: peerConnectionController!.myPeerId,
        username: userModelController.user!.username
    );
    gameModelDTO!.player.currentCredit = gameModelDTO!.initalGameCredit;
    gameModelDTO!.updateOtherPlayers(event.sourcePlayer); //add hostplayer as otherplayer
    gameModelDTO!.updateOtherPlayers(gameModelDTO!.player);
    _sendEvent(EventDTO(
        referenceRound: 0,
        type: EventType.joinTable,
        destinationPlayer: event.sourcePlayer,
        sourcePlayer: gameModelDTO!.player,
        value: 0));
    isLoading = false;
    notifyListeners();
  }
}
