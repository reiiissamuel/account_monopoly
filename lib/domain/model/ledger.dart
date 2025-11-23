
import 'dart:math';

import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/model/loan.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/domain/model/shares_holder_summary.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/utils/configs_constants.dart';
import 'package:logger/logger.dart';

class Ledger {

  var logger = Logger(printer: PrettyPrinter(methodCount: 0));

  final Map<String, Property> properties; 
  final String bankId = "bank";
  int lastPropertiesUpdateRound ; // indica numero do round no qual o metodo updatePropertiesValuation foi chamado pela ultima vez
  double roundBonus = 0.0;
  double currentInterestRate;
  double propertyProfitTaxRate;
  double lateFeeRate = 0.05;
  double incomeTaxRate = 0.10;
  Map<String, Player> badCreditList = {};
  Map<String, TradeOffer> tradeOffers; 
  
  Map<String, ShareHolder> bankPortfolio = {}; // ações adiquirdas pelo banco através de execuções hipotecárias
  
  Ledger({
    required this.properties,
    required this.currentInterestRate,
    required this.propertyProfitTaxRate,
    required this.roundBonus,
    required this.incomeTaxRate,
    required this.lateFeeRate,
    this.lastPropertiesUpdateRound = 0,
    Map<String, TradeOffer> tradeOffers = const {}
  }) : tradeOffers = Map.from(tradeOffers);

  Ledger.empty() :
        lastPropertiesUpdateRound = 0,
    properties = {},
    currentInterestRate = 0.05,
    propertyProfitTaxRate = 0.15,
    tradeOffers = {};

  bool isBlacklisted(String playerId){
    return badCreditList.containsKey(playerId);
  }

  Property updatePropertyPayout(String propertyId, double newPayout){
    properties[propertyId]!.payoutPercentage = newPayout;
    return properties[propertyId]!;
  }

  SharesHolderSummary getSharesHolderSummary(Map<String, ShareHolder> portfolio){
    double totalPortfolioValue = 0;
    double totalInvested = 0;
    double totalDividends = 0;
    for(ShareHolder shareHolder in portfolio.values){
      double currentShareCost = properties[shareHolder.propertyId]!.sharePrice;
      totalPortfolioValue += shareHolder.portfolioValue(currentShareCost);
      totalInvested += shareHolder.investmentValue;
      totalDividends += shareHolder.dividendsReceived;
    }

    return SharesHolderSummary(
      totalPortfolioValue: totalPortfolioValue,
      totalInvested: totalInvested,
      totalDividends: totalDividends
    );

  }

  double calculateShareHolderValue(ShareHolder item){
    final shareCurrentCost = properties[item!.propertyId]!.sharePrice;
    return item.portfolioValue(shareCurrentCost);
  }

// FUNÇÔES AUXILIAR: GESTÃO DOS PAGAMENTOS
  Property processRentPayment(Player player, String propertyId, double rentToPay) {
    final property = properties[propertyId];
    player.payDebit(rentToPay);
    property!.collectedRent += rentToPay;
    return property;
  }

  void processIncomeTaxPayment(Player player) {
    final taxAmount = player.incomeTax;
    final refund = taxAmount * (Random().nextDouble() * 0.3); // 10% a 30% de reembolso
    player.payDebit(taxAmount);
    player.taxRefund = refund;
    player.incomeTax = 0.0;
    player.roundBalance.incomeTaxOut += taxAmount;
  }

  double processTaxRefund(Player player) {
    final refund = player.taxRefund;
    player.receiveCredit(refund, 0);
    player.taxRefund = 0.0;
    player.roundBalance.otherIn += refund;
    return refund;
  }

  void processLoanAcquisition(Player player, Loan loan) {

    if(loan.type == LoanType.bankLoan){
      bool hasBonnusLoan = player.loans.any(((l) => l.type == LoanType.bankLoan && !l.isPaidOff));
      if(hasBonnusLoan) throw MaxBonnusLoansException(ConfigsConstants.maxBonnusLoansErrorMsg);
    } else {
      bool existingCollateralid = player.loans.any(((l) => l.collateralId == loan.collateralId));
      if(existingCollateralid) throw MortgagedPropertyException(ConfigsConstants.mortgagedPropertyErrorMsg);
    }

    player.receiveCredit(loan.principalBorrowed, 0);
    player.loans.add(loan);
    player!.roundBalance.otherIn += loan.principalBorrowed;
  }

  void processLoanPayment(Player player, String loandId, double paymentAmount) {
    var loan = player.loans.firstWhere((l) => l.id == loandId);

    final payment = paymentAmount > loan.remainingDebt ? loan.remainingDebt : paymentAmount;
    player.payDebit(paymentAmount);
    player.roundBalance.otherOut += payment;
    loan.principalPaid += payment;

    if(loan.isPaidOff) {
      badCreditList.remove(player.id);
    }
    print('✅ ${player.username} pagou o empréstimo ${loan.id} integralmente.');

  }

  void processRoundBonus(Player player) {
    player.receiveCredit(roundBonus, incomeTaxRate);
    player.roundBalance.bonusIn += roundBonus;
  }

// FUNÇÔES AUXILIAR: GESTÃO DAS AÇÔES E NEGOCIAÇÕES
  Property buyFromIPO(Player buyer, String propertyId, int sharesAmount) {
    if(isBlacklisted(buyer.id)) throw(Exception(ConfigsConstants.blackListErrorMsg));
    final totalCost = properties[propertyId]!.sharePrice * sharesAmount;
    buyer.payDebit(totalCost);
    buyer.roundBalance.sharePurchasesOut += totalCost;

    properties[propertyId]!.availableShares -= sharesAmount;
    buyer.upgradePortfolio(propertyId, sharesAmount, totalCost);
    logger.i('✅ ${buyer.username} adquiriu $sharesAmount ações de $propertyId por ${totalCost.toStringAsFixed(2)}');
    return properties[propertyId]!;
  }

  void setTradeOffer(Player player, TradeOffer offer) {
    final isAbleToTrade = player.portfolio.values.any((s) => s.propertyId == offer.propertyId && s.sharesOwned >= offer.sharesAmount);
    if (isAbleToTrade) {
      tradeOffers[offer.offerId] = offer;
    } else {
      throw NotEnoughSharesToTradeException(ConfigsConstants.notEnoughSharesToTradeErrorMsg);
    }
  }
  
  void buyFromTrade(Player buyer, TradeOffer tradeOffer, Player? seller) {
    //var offer = tradeOffers[tradeOffer.offerId];

    final totalCost = tradeOffer.totalAskingPrice;
    final amount = tradeOffer.sharesAmount;
    final propertyId = tradeOffer.propertyId;

    buyer.payDebit(totalCost);
    buyer.roundBalance.sharePurchasesOut += totalCost;

    if(seller != null){
      seller.receiveCredit(totalCost, incomeTaxRate);
      seller.roundBalance.shareSalesIn += totalCost;
      _transferSharesP2P(
        propertyId: propertyId,
        sharesAmount: amount,
        transactionCost: totalCost,
        fromPlayer: seller,
        toPlayer: buyer,
      );
    } else {
      _transferSharesBank2P(propertyId: propertyId, sharesAmount: amount, transactionCost: totalCost, toPlayer: buyer);
    }
    
    // 4. FINALIZAÇÃO
    finishTradeOffer(tradeOffer.offerId);
  }

  void finishTradeOffer(String offerId){
    tradeOffers.remove(offerId);
  }

  void updatePropertiesValuation(Player player, int referenceRound){
    properties.forEach((id, property) {
      double netRetainedProfit = property.profitToRetain * (1.0 - propertyProfitTaxRate);
      _distributePayout(player, property, referenceRound);
      property.applyValuation(netRetainedProfit, referenceRound);
    });
    lastPropertiesUpdateRound = referenceRound;
  }
 
  void _distributePayout(Player player, Property property, int referenceRound) {
    ShareHolder? item = player.portfolio[property.id];
    if(item != null){
      double dividendReceived = property.currentDividendsPerShare * item.sharesOwned;
      player.receiveCredit(dividendReceived, incomeTaxRate);
      player.roundBalance.dividendsIn += dividendReceived;
      item.dividendsReceived += dividendReceived;
      property.lastDividendRound = referenceRound;
      logger.i('${player.username} recebeu ${dividendReceived.toStringAsFixed(2)} da ${property.name}');
    }
  }
  
  void _transferSharesP2Bank({
    required String propertyId,
    required int sharesAmount,
    required double transactionCost,
    required fromPlayer
  }) {
    final property = properties[propertyId];
    var fromPortfolio = fromPlayer != null ? fromPlayer.portfolio : bankPortfolio;
    
    final fromShareholder = fromPortfolio[propertyId];

    if (fromShareholder == null || fromShareholder.sharesOwned < sharesAmount) {
      throw Exception("O remetente não tem $sharesAmount ações de ${property!.name} para transferir.");
    }

    // A. REMOÇÃO do Emissor (FROM)
    fromPlayer.downgradePortfolio(propertyId, sharesAmount, transactionCost);

    // B. ADIÇÃO no Receptor (TO)
    if (bankPortfolio.containsKey(propertyId)) {
      bankPortfolio[propertyId]!.sharesOwned += sharesAmount;
    } else {
      bankPortfolio[propertyId] = ShareHolder(
        playerId: bankId,
        propertyId: propertyId,
        sharesOwned: sharesAmount,
        investmentValue: transactionCost,
        saleCapitalGain: 0
      );
    }
  }

  void _transferSharesBank2P({
    required String propertyId,
    required int sharesAmount,
    required double transactionCost,
    required Player toPlayer
  }) {
    final property = properties[propertyId];
    final bankShareholder = bankPortfolio[propertyId];

    if (bankShareholder == null || bankShareholder.sharesOwned < sharesAmount) {
      throw Exception("O remetente não tem $sharesAmount ações de ${property!.name} para transferir.");
    }

    // A. REMOÇÃO do Emissor (FROM)
    if (sharesAmount >= bankShareholder.sharesOwned) {
      bankPortfolio.remove(bankShareholder.propertyId);
    } else {
      bankShareholder.sharesOwned -= sharesAmount;
    }

    // B. ADIÇÃO no Receptor (TO)
    toPlayer.upgradePortfolio(propertyId, sharesAmount, transactionCost);
  }

  void _transferSharesP2P({
    required String propertyId,
    required int sharesAmount,
    required double transactionCost,
    required fromPlayer,
    required toPlayer,
  }) {
    final property = properties[propertyId];
    var fromPortfolio = fromPlayer.portfolio;
    
    final fromShareholder = fromPortfolio[propertyId];

    if (fromShareholder == null || fromShareholder.sharesOwned < sharesAmount) {
      throw Exception("O remetente não tem $sharesAmount ações de ${property!.name} para transferir.");
    }

    // A. REMOÇÃO do Emissor (FROM)
    fromPlayer.downgradePortfolio(propertyId, sharesAmount, transactionCost);

    // B. ADIÇÃO no Receptor (TO)
    toPlayer.upgradePortfolio(propertyId, sharesAmount, transactionCost);
  }

  void checkForMajorOwner(Player player, String propertyId) {
    final shareholderData = player.portfolio[propertyId];
    var property = properties[propertyId];
    if (property == null) return;
    
    if (shareholderData!.sharesOwned > property.totalShares / 2) {
      property.majorOwnerId = player.id;
    } else if (property.majorOwnerId == player.id) {
      property.majorOwnerId = "";
    }
  }
  
  void checkTradeOffersDeadline(){
    tradeOffers.forEach((key, offer) => offer.turnsToEnd -= 1 );
    tradeOffers.removeWhere((key, offer) => offer.turnsToEnd < 1);
  }

  // FUNÇÔES AUXILIAR: GESTÃO DAS DÍVIDAS
  List<Loan> managePlayerLoans(Player player) {
    List<Loan> foreclosuredLoans = List<Loan>.empty(growable: true);
    if (player.loans.isEmpty) return foreclosuredLoans;

    for (var loan in player.loans) {
      if (loan.isPaidOff) continue;
      loan.reduceTerm(); 
      if (loan.roundsToPayOff <= 0) {
        _handleLoan(player, loan, foreclosuredLoans);
      }
      _handleLoanLate(player, loan, foreclosuredLoans);
    }
    player.loans.removeWhere((loan) => loan.isPaidOff);
    return foreclosuredLoans;
  }

  void _handleLoan(Player player, Loan loan, List<Loan> foreclosuredLoans) {
    if (loan.type == LoanType.mortgage && loan.collateralId != null) {
      _executeMortgage(player, loan, foreclosuredLoans);
      loan.totalDue = 0;
    } else if (loan.type == LoanType.bankLoan) {
      _applyLateFee(player, loan);
    }
  }

  void _handleLoanLate(Player player, Loan loan, List<Loan> foreclosuredLoans) {
    // Esta lógica foi simplificada para ser executada em um ponto específico

    if (loan.roundsToPayOff <= -3) {
      if (player.currentCredit >= loan.totalDue) {
        player.payDebit(loan.totalDue);
        player.roundBalance.otherOut += loan.totalDue;
        badCreditList.remove(player.id);
        foreclosuredLoans.add(loan);
        print('✅ ${player.username} teve o empréstimo ${loan.id} pago forçadamente.');
      } else {
        player.youBankrupt = true;
        print('❌ ${player.username} está em falência e não pode cobrir o empréstimo ${loan.id}.');
      }
    }
  }

  void _executeMortgage(Player player, Loan loan,  List<Loan> foreclosuredLoans) {
    var property = properties[loan.collateralId!];
    if (property == null) return;
    final sharesToConfiscate = loan.collateralAmountShares;
    
    if (sharesToConfiscate! > 0) {
        _transferSharesP2Bank(
            propertyId: property.id, 
            sharesAmount: sharesToConfiscate,
            transactionCost: 0,
            fromPlayer: player,
        );
        player.roundBalance.otherOut += sharesToConfiscate * property.sharePrice;
        foreclosuredLoans.add(loan);
        logger.i('🚫 ${player.username} perdeu ${property.name} por execução de hipoteca.');
    }
  }

  void _applyLateFee(Player player, Loan loan) {
    loan.totalDue *= (1.0 + lateFeeRate); // Aplica multa (lateFeeRate deve ser um atributo/constante)
    badCreditList[player.id] = player; // Adiciona à lista de mau crédito
    print('⚠️ ${player.username} sofreu multa no empréstimo ${loan.id}. Novo total: ${loan.totalDue.toStringAsFixed(2)}');
  }

// FUNÇÔES AUXILIAR: GESTÃO DE CONSTRUÇÔES
  Property processBuildingPurchase(Player player, String propertyId, int newBuildings, double buildingRentIncrease, int markupUsagePercentage) {
    var property = properties[propertyId];
    var totalCost = newBuildings * property!.currentBuildingCost;
    var markupUsageCost = totalCost * (markupUsagePercentage/100);
    var playerCost = totalCost - markupUsageCost;
    try{
      if(isBlacklisted(player.id)) throw(BlackListedException(ConfigsConstants.blackListErrorMsg));
      property.checkIfEnoughMarkup(markupUsageCost);
      
      player.payDebit(playerCost);
      property.addBuilding(buildingRentIncrease, newBuildings, markupUsageCost);
      player.roundBalance.buildingPurchasesOut += playerCost;
      logger.i('🏗️ ${player.username} construiu em ${property.name}.');
      return property;
    } on MaxBuildingsException {
      player.receiveCredit(playerCost, 0);
      rethrow;
    } 
  }

// =========================================================================
  // MÉTODOS DE SERIALIZAÇÃO
  // =========================================================================

  Map<String, dynamic> toMap() {
    return {
      'properties': properties.map((k, v) => MapEntry(k, v.toMap())),
      'badCreditList': badCreditList.map((k, v) => MapEntry(k, v.toMap())),
      'bankPortfolio': bankPortfolio.map((k, v) => MapEntry(k, v.toMap())),
      'bankId': bankId,
      'roundBonus': roundBonus,
      'currentInterestRate': currentInterestRate,
      'propertyProfitTaxRate': propertyProfitTaxRate,
      'lateFeeRate': lateFeeRate,
      'incomeTaxRate': incomeTaxRate,
    };
  }

  factory Ledger.fromMap(Map<String, dynamic> map) {
    Map<String, Property> deserializeProperties(Map<String, dynamic> data) {
      return data.map((k, v) => MapEntry(k, Property.fromMap(v as Map<String, dynamic>)));
    }

    Map<String, Player> deserializePlayers(Map<String, dynamic> data) {
      return data.map((k, v) => MapEntry(k, Player.fromMap(v as Map<String, dynamic>)));
    }

    Map<String, ShareHolder> deserializeShareHolders(Map<String, dynamic> data) {
      return data.map((k, v) => MapEntry(k, ShareHolder.fromMap(v as Map<String, dynamic>)));
    }

    // 2. Instanciação usando o construtor principal (para campos required/final)
    final propertiesMap = (map['properties'] as Map<String, dynamic>? ?? {});
    
    final ledger = Ledger(
      properties: deserializeProperties(propertiesMap),
      currentInterestRate: map['currentInterestRate'] as double? ?? 0.05,
      propertyProfitTaxRate: map['propertyProfitTaxRate'] as double? ?? 0.15,
      roundBonus: map['roundBonus'] as double? ?? 0.0,
      incomeTaxRate: map['incomeTaxRate'] as double? ?? 0.10,
      lateFeeRate: map['lateFeeRate'] as double? ?? 0.05,
    );
    // População de campos mutáveis (não-finais) após a instanciação
    
    // badCreditList (Map mutável)
    ledger.badCreditList.addAll(deserializePlayers((map['badCreditList'] as Map<String, dynamic>? ?? {})));

    // bankPortfolio (Map final/mutável)
    ledger.bankPortfolio.addAll(deserializeShareHolders((map['bankPortfolio'] as Map<String, dynamic>? ?? {})));

    return ledger;
  }
}