
import 'dart:async';
import 'dart:developer';
import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:account_monopoly/domain/model/event_dto.dart';
import 'package:account_monopoly/domain/model/game.dart';
import 'package:account_monopoly/domain/model/ledger.dart';
import 'package:account_monopoly/domain/model/loan.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/exception/game_not_exists_exception.dart';
import 'package:account_monopoly/provider/user_provider.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/service/game_peer_service.dart';
import 'package:flutter/material.dart';
import 'package:account_monopoly/domain/enums/event_type.dart';
import 'package:peer_rtc/peer_rtc.dart';

class GameProvider extends ChangeNotifier {
  late UserProvider userModelController;
  GamePeerService? peerService;
  GameModelDTO? gameModelDTO;
  bool isLoading = false;
  List<EventDTO> events = [];
  EventDTO? lastEventReceived;
  String? any;

  GameProvider({required this.userModelController});

  Ledger get ledger => gameModelDTO!.ledger;
  Player get currentPlayer => gameModelDTO!.player;
  Map<String, Player> get otherPlayers => gameModelDTO!.othersPlayers;
  int get currentRound => gameModelDTO!.player.financialReport.historicalBalances.length + 1;
  bool get isServer => peerService?.isServer ?? false;
  
  void reset(){
    gameModelDTO = GameModelDTO.empty();
    isLoading = false;
    events = [];
    lastEventReceived = null;
  }

  void notifyChanges(bool isLoading) {
    this.isLoading = isLoading;
    notifyListeners();
  }

  void _initHostTunnel(String peerId) {
    Future.microtask(() async {
      peerService?.destroy();
      
      final peer = Peer(id: peerId);
      peerService = GamePeerService(
        peer: peer,
        myPeerId: peerId
      );
      
      // CRUCIAL: Assina as streams para o Host também processar os eventos recebidos
      _listenToPeerService();
      await peerService!.startAsHost();
    });
  }

  // Método auxiliar para escutar os fluxos vindos da rede de forma limpa
  void _listenToPeerService() {
    peerService?.onData.listen((incomingData) {
      try {
        processComingEvent(EventDTO.fromMap(incomingData['data']));
      } catch (e) {
        log("Erro ao processar dados da stream no provider: $e");
      }
    });

    peerService?.onPeerLeft.listen((peerId) {
      eventComposer(
        type: EventType.lostConnection, 
        sourcePlayer: gameModelDTO?.othersPlayers[peerId]
      );
    });
  }

  void _sendEvent(EventDTO event) {
    peerService?.send(event);
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
    
    double? price = event.price;
    int? quantity = event.quantity;
    Player? destinationPlayer = event.destinationPlayer;

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
        //TODO vericar: caso seja proximo na lista de conexão, abre host, caso contrario tenta se conectar com proximo horst
        break;
      case EventType.iwon:
        gameModelDTO!.winner = sourceplayer;
        break;
      case EventType.joinTable:
        sourceplayer.isOnline = true;
        // Se eu sou o Host e recebi o aviso de que um cliente entrou na mesa,
        // eu respondo enviando o estado completo do jogo (serverHandShake) para ele.
        // Envolve o envio em microtask para evitar conflito no Stream Controller da lib de peer_rtc
        if (isServer && sourceplayer.id != currentPlayer.id) {
          Future.microtask(() {
            eventComposer(type: EventType.serverHandShake, destinationPlayer: sourceplayer);
          });
        }
      case EventType.serverHandShake:
        final bool isNewPlayerAtTable = gameModelDTO == null || gameModelDTO!.isEmpty;
        if((isNewPlayerAtTable || destinationPlayer?.id == currentPlayer.id)) {
            sourceplayer.isOnline = true;
            _dealHostHandShakeEvent(event, destinationPlayer!, isNewPlayerAtTable);
        }
        break;
      case EventType.lostConnection:
        if (gameModelDTO!.othersPlayers.containsKey(sourceplayer.id)) {
          gameModelDTO!.othersPlayers[sourceplayer.id]!.isOnline = false;
        }
        _updateUserModel();
        break;
      default:
        break;
    }
    
    gameModelDTO!.updateOtherPlayers(sourceplayer); //atualiza o estado do jogador que enviou o evento
    gameModelDTO!.updateOtherPlayers(destinationPlayer); //atualiza o estado do jogador que recebeu o evento
    gameModelDTO!.logs.add(event.getEventLog(currentPlayer));
  }

  void processRoundEnding() {
    try{
      eventComposer(type: EventType.roundBonus, price: ledger.roundBonus);
      eventComposer(type: EventType.dividendsCalculation);
      currentPlayer.financialReport.addRoundBalance(currentRound, currentPlayer.roundBalance.copyAndReset());

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
          referenceRound: currentRound,
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
          if(ledger.lastPropertiesUpdateRound >= currentRound) throw PropertiesAlreadyUpdateException("");
          ledger.updatePropertiesValuation(currentPlayer, currentRound);
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
          event.gameData = gameModelDTO;
          _updateUserModel();
          break;
        case EventType.lostConnection:
          event.sourcePlayer.isOnline = false;
          _updateUserModel();
          //gameModelDTO!.othersPlayers.remove(currentPlayer.id);
          break;
        default:
          break;
      }
      
      gameModelDTO!.updateOtherPlayers(destinationPlayer);
      gameModelDTO!.updateOtherPlayers(sourcePlayer);
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

      gameModelDTO = game;
      gameModelDTO!.player = Player.newGamePlayer(
          currentCredit: game.initalGameCredit,
          userModelId: usermodelId,
          gameId: game.id,
          username: usermodelname
      );
      gameModelDTO!.updateOtherPlayers(gameModelDTO!.player);
      _initHostTunnel(gameModelDTO!.player.id);
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

  Future<void> enterGameRequest({GameModelDTO? game, String? destinationPeerId}) async {
    try {
      userModelController.notifyChanges(true);
      final Player player;
      
      final resolvedGameId = destinationPeerId?.split("-").last;
      gameModelDTO = game ?? userModelController.getGameById(resolvedGameId!);
      
      if(gameModelDTO!.isEmpty){
        player = Player.newGamePlayer(
          userModelId: userModelController.user!.id!,
          gameId: resolvedGameId!,
          username: userModelController.user!.username
        );
      } else {
        player = gameModelDTO!.player;
      }
      
      peerService?.destroy();
      peerService = GamePeerService(
        peer: Peer(id: player.id),
        myPeerId: player.id
      );
      _listenToPeerService(); // Assina as streams antes de conectar
      await peerService!.connectToHost(
        player: player,
        destinationPeerId: destinationPeerId,
        canditadesPeersId: gameModelDTO!.othersPlayers.keys.toList()
      );

      notifyChanges(false);
    } on TimeoutException {
      if(gameModelDTO != null && !gameModelDTO!.isEmpty){
        _initHostTunnel(gameModelDTO!.player.id);
      } else {
        throw GameNotExistsException();
      }
    } catch(e) {
      log("Erro: $e");
      rethrow;
    } finally {
      userModelController.notifyChanges(false);
    }
  }

  void leaveGame() {
    try {
      // 1. Envia o evento de desconexão para a mesa antes de fechar tudo
      if (peerService != null && peerService!.isPeerConnected) {
        eventComposer(type: EventType.lostConnection);
      }
    } catch (e) {
      log("Erro ao notificar saída do jogo: $e");
    } finally {
      // 2. Destrói o StarHub/Peer e limpa o estado local
      peerService?.destroy();
      reset();
    }
  }

  Future<void> _updateUserModel() async {
    try{
      // --- CORREÇÃO AQUI: Remove a referência antiga da partida antes de adicionar a atualizada 
      userModelController.user!.games.removeWhere((g) => g.id == gameModelDTO!.id);
      // Adiciona a versão atualizada e unificada do jogo
      userModelController.user!.games.add(gameModelDTO!);
      await userModelController.updateUser();
    } on Exception catch(e){
      log("Erro na tentativa salvar os dados do jogo: $e");
      rethrow;
    }
  }

  void _dealHostHandShakeEvent(EventDTO event, Player localPlayer, bool isNewPlayerAtTable) {
    
    // Recebe os dados globais do novo host
    gameModelDTO = event.gameData;

    gameModelDTO!.player = localPlayer;
    if(isNewPlayerAtTable){
      gameModelDTO!.player.currentCredit = gameModelDTO!.initalGameCredit;
    }
    
    // Persiste o estado unificado localmente
    _updateUserModel();

    isLoading = false;
    notifyListeners();
  }
}
