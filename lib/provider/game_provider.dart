
import 'dart:developer';

import 'package:account_monopoly/configuration/peer_connection_controller_v2.dart';
import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/game.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/loan.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/utils/string_utils.dart';
import 'package:account_monopoly/exception/game_already_in_player_list_exception.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';

import 'package:account_monopoly/domain/enums/event_type.dart';

class GameProvider extends ChangeNotifier {
  late UserProvider userModelController;
  PeerConnectionControllerV2? peerConnectionController;
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

  GameProvider({required this.userModelController});

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
      double? price = event.price;
      int? quantity = event.quantity;
      Player ?destinationPlayer = event.destinationPlayer;

      if(sourceplayer.id == currentPlayer.id) return;
      gameModelDTO!.updateOtherPlayers(sourceplayer); //atualiza o estado do jogador que enviou o evento
      gameModelDTO!.updateOtherPlayers(destinationPlayer); //atualiza o estado do jogador que recebeu o evento
      switch (event.type) {
        case EventType.removeTradeOffer:
          ledger.removeTradeOffersByKey(event.tradeOffer!.offerId);
          break;
        case EventType.transfer:
          if(destinationPlayer!.id == currentPlayer.id){
            currentPlayer.roundBalance.transferIn += price!;
            currentPlayer.receiveCredit(price, ledger.incomeTaxRate);
          } 
          break;
        case EventType.build || EventType.propertyUpdatePayout || EventType.payRent:
          ledger.properties[event.property!.id] = event.property!;
          break;
        case EventType.setTradeOffer:
          ledger.tradeOffers[event.tradeOffer!.offerId] = event.tradeOffer!;
          break;
        case  EventType.buyFromIPO:
          ledger.properties[event.property!.id] = event.property!;
          ledger.checkForMajorOwner(sourceplayer, event.property!.id);
          break;
        case EventType.buyFromTrade:
          if(destinationPlayer!.id == currentPlayer.id){
            currentPlayer.receiveCredit(event.tradeOffer!.totalAskingPrice, ledger.incomeTaxRate);
            currentPlayer.roundBalance.shareSalesIn += event.tradeOffer!.totalAskingPrice;
            currentPlayer.downgradePortfolio(event.tradeOffer!.propertyId, event.tradeOffer!.sharesAmount, event.tradeOffer!.totalAskingPrice);
          } 
          ledger.checkForMajorOwner(sourceplayer, event.tradeOffer!.propertyId);
          ledger.checkForMajorOwner(destinationPlayer, event.tradeOffer!.propertyId);
          ledger.removeTradeOffersByKey(event.tradeOffer!.offerId);
          break;
        case EventType.mortgageForeclosure:
          ledger.bankPortfolio[event.property!.id] = ShareHolder(
              playerId: sourceplayer.id,
              propertyId: event.property!.id,
              sharesOwned: quantity!,
              investmentValue: 0,
              saleCapitalGain: 0);
          ledger.properties[event.property!.id] = event.property!;
          break;
        case EventType.dividendsCalculation:
          if(ledger.lastPropertiesUpdateRound >= event.referenceRound) return;
          ledger.updatePropertiesValuation(currentPlayer, event.referenceRound);
          event.price = currentPlayer.roundBalance.dividendsIn;
          break;
        case EventType.saveGame:
          _updateUserModel();
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
          gameModelDTO!.updateOtherPlayers(sourceplayer); //duplicado, sourceplayer já é inserido no incio do metodo
          break;
        case EventType.lostConnection:
          gameModelDTO!.othersPlayers.remove(sourceplayer.id);
        default:
          break;
      }
    }

    gameModelDTO!.logs.add(event.getEventLog(currentPlayer));
  }

  void processRoundEnding() {
    try{
      eventComposer(type: EventType.roundBonus, price: ledger.roundBonus);
      eventComposer(type: EventType.dividendsCalculation);
      currentPlayer.financialReport.addRoundBalance(gameModelDTO!.currentRound, currentPlayer.roundBalance.copyAndReset());
      gameModelDTO!.currentRound += 1;

      List<Loan> foreclosureLoans = gameModelDTO!.ledger.managePlayerLoans(gameModelDTO!.player);
      if(foreclosureLoans.isNotEmpty){
        for(var loan in foreclosureLoans){
          if(loan.type == LoanType.bankLoan){
            eventComposer(type: EventType.loanForeclosure, price: loan.totalDue);
          }
          else if(loan.type == LoanType.mortgage){
            eventComposer(type: EventType.mortgageForeclosure, propertyId: loan.collateralId);
          }
        }
      }

      if (ledger.badCreditList.containsKey(currentPlayer.id)){
        eventComposer(type: EventType.bankBlacklisted);
      }

      List<TradeOffer> expiredOffersIds = ledger.updatePlayerTradeOffersDeadline(currentPlayer.id);
      for (var offer in expiredOffersIds) {
        eventComposer(type: EventType.removeTradeOffer, tradeOffer: offer);
      }
      
      eventComposer(type: EventType.saveGame);
    } on Exception{
      notifyChanges(false);
      rethrow;
    }
  }

  void eventComposer({required EventType type, Player? destinationPlayer, Player? sourcePlayer, int? quantity, double? price, int? reserveUsage,
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
          price: price,
          quantity: quantity
      );

      switch (event.type) {
        case EventType.propertyUpdatePayout:
          event.property = ledger.updatePropertyPayout(propertyId!, price!);
          break;
        case EventType.payRent:
          event.property = ledger.processRentPayment(currentPlayer, propertyId!, price!);
          break;
        case EventType.payTax:
          event.price = currentPlayer.incomeTax;
          ledger.processIncomeTaxPayment(currentPlayer);
          break;
        case EventType.receiveTax:
          event.price = ledger.processTaxRefund(currentPlayer);
          break;
        case EventType.roundBonus:
          ledger.processRoundBonus(currentPlayer);
          break;
        case EventType.payBank:
          currentPlayer.payDebit(price!);
          currentPlayer.roundBalance.otherOut += price;
          break;
        case EventType.receiveFromBank:
          currentPlayer.receiveCredit(price!, ledger.incomeTaxRate);
          currentPlayer.roundBalance.otherIn += price;
          break;
        case EventType.transfer:
          currentPlayer.payDebit(price!);
          currentPlayer.roundBalance.transferOut += price;
          destinationPlayer!.receiveCredit(price, ledger.incomeTaxRate);
          destinationPlayer.roundBalance.transferIn += price;
          break;
        case EventType.loan:
          ledger.processLoanAcquisition(currentPlayer, loan!);
          break;
        case EventType.loanPayment:
          ledger.processLoanPayment(currentPlayer, loan!.id, price!);
          break;
        case EventType.mortgageForeclosure:
          event.property = ledger.properties[propertyId];
          ledger.checkForMajorOwner(currentPlayer, event.property!.id);
          break;
        case EventType.buyFromIPO:
          event.property = ledger.buyFromIPO(currentPlayer, propertyId!, quantity!);
          ledger.checkForMajorOwner(currentPlayer, propertyId);
          break;
        case EventType.setTradeOffer:
          ledger.setTradeOffer(currentPlayer, tradeOffer!);
          break;
        case EventType.removeTradeOffer:
          ledger.removeTradeOffersByKey(tradeOffer!.offerId);
          break;
        case EventType.buyFromTrade:
          ledger.buyFromTrade(currentPlayer, tradeOffer!, destinationPlayer);
          ledger.checkForMajorOwner(currentPlayer, event.tradeOffer!.propertyId);
          ledger.checkForMajorOwner(destinationPlayer!, event.tradeOffer!.propertyId);
          break;
        case EventType.dividendsCalculation:
          if(ledger.lastPropertiesUpdateRound >= gameModelDTO!.currentRound) throw PropertiesAlreadyUpdateException("");
          ledger.updatePropertiesValuation(currentPlayer, gameModelDTO!.currentRound);
          event.price = currentPlayer.roundBalance.dividendsIn;
          break;
        case EventType.build:
          event.property = ledger.processBuildingPurchase(currentPlayer, propertyId!, newBuildings!, price!, reserveUsage!);
          break;
        case EventType.saveGame:
          _updateUserModel();
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
          //gameModelDTO!.othersPlayers[destinationPlayer!.id] = destinationPlayer; ja salva na linha 274
          event.gameData = gameModelDTO;
          _updateUserModel();
          break;
        case EventType.lostConnection:
          gameModelDTO!.othersPlayers.remove(currentPlayer.id);
          //todo salvar jogo e sair;
          break;
        default:
          break;
      }

      if(destinationPlayer != null){
        gameModelDTO!.updateOtherPlayers(destinationPlayer);
      } 
      _sendEvent(event);
      gameModelDTO!.logs.add(event.getEventLog(currentPlayer));
      notifyChanges(false);
    } on PropertiesAlreadyUpdateException{
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
        sellerName: ledger.bankId,
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
        sellerName: ledger.bankId,
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
      sellerName: offer.sellerName,
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

  Future<void> createNewGame({required GameModelDTO game}) async {
    try{
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
      peerConnectionController!.reconnectToLastHost();
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
        throw GameAlreadyInPlayerListException();
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
    // Destrói o peer anterior se ele já existir, evitando conflitos de socket e stream
    if (peerConnectionController != null) {
      peerConnectionController!.destroy();
      peerConnectionController = null;
    }

    Peer peer = Peer(id: peerId);
    peerConnectionController = PeerConnectionControllerV2(
      gameModelController: this, 
      peer: peer, 
      myPeerId: peerId,
    );
  }

  Future<void> _updateUserModel() async {
    try{
      await userModelController.updateUser();
    } on Exception catch(e){
      log("Erro na tentativa salvar os dados do jogo: $e");
      rethrow;
    }
  }

  static String _generatePlayerId({required usermodelname, required usermodelId, required gameId}){
    return "$usermodelname-$usermodelId-${StringUtils.generateUUID(size: 5)}-$gameId";
  }

  void _dealHostHandShakeEvent(EventDTO event) {
    // 1. O Host enviou o estado completo do jogo em event.gameData
    gameModelDTO = event.gameData;

    final myId = peerConnectionController!.myPeerId;

    // 2. Verifica se o Host já mapeou este jogador na lista (seja por reconexão ou nova entrada)
    if (gameModelDTO!.othersPlayers.containsKey(myId)) {
      // Restaura o player exato com todo o saldo, propriedades e histórico guardados
      gameModelDTO!.player = gameModelDTO!.othersPlayers[myId]!;
    } else {
      // Fallback de segurança para um jogador totalmente novo caso não venha no mapa
      gameModelDTO!.player = Player.ofDefinedId(
        id: myId,
        username: userModelController.user!.username,
      );
      gameModelDTO!.player.currentCredit = gameModelDTO!.initalGameCredit;
      gameModelDTO!.othersPlayers[myId] = gameModelDTO!.player;
    }

    // 3. Notifica a mesa que o jogador está ativo / na mesa
    _sendEvent(EventDTO(
      referenceRound: 0,
      type: EventType.joinTable,
      destinationPlayer: event.sourcePlayer,
      sourcePlayer: gameModelDTO!.player,
    ));

    isLoading = false;
    notifyListeners();
  }
}


