
import 'dart:math';

import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/model/loan.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';

class Ledger {
  final Map<String, Property> properties; 
  final String bankId = "bank";
  double roundBonus = 0.0;
  double currentInterestRate;
  double propertyProfitTaxRate;
  double lateFeeRate = 0.05;
  double incomeTaxRate = 0.10;
  Map<String, Player> badCreditList = {};
  final Map<String, TradeOffer> tradeOffers;
  
  final Map<String, ShareHolder> bankPortfolio = {}; // ações adiquirdas pelo banco através de execuções hipotecárias
  
  Ledger({
    required this.properties,
    required this.currentInterestRate,
    required this.propertyProfitTaxRate,
    required this.roundBonus,
    required this.incomeTaxRate,
    required this.lateFeeRate,
    this.tradeOffers = const {},
  });

  Ledger.empty() : 
    properties = {},
    currentInterestRate = 0.05,
    propertyProfitTaxRate = 0.15,
    tradeOffers = {};

  bool isBlacklisted(String playerId){
    return badCreditList.containsKey(playerId);
  }

// FUNÇÔES AUXILIAR: GESTÃO DOS PAGAMENTOS
  void processRentPayment(Player player, String propertyId) {
    final property = properties[propertyId];
    if (property == null) return;
    final rentAmount = property.currentRent;
    player.payDebit(rentAmount);
    property.collectedRent += rentAmount;
  }

  void processIncomeTaxPayment(Player player) {
    final taxAmount = player.incomeTax;
    player.payDebit(taxAmount);
    player.incomeTax = 0.0;
    player.roundBalance.incomeTaxOut += taxAmount;
  }

  double processTaxRefund(Player player) {
    double refund = player.incomeTax * (0.1 + Random().nextInt(21)); // 10% a 30% de reembolso
    player.receiveCredit(refund, 0);
    player.roundBalance.otherIn += refund;
    return refund;
  }

  void processLoanPayment(Player player, String loandId, double paymentAmount) {
    var loan = player.loans.firstWhere((l) => l.id == loandId);
    if (player.currentCredit >= paymentAmount && paymentAmount <= loan.totalDue) {
      player.payDebit(paymentAmount);
      player.roundBalance.otherOut += paymentAmount;
      loan.principalPaid += paymentAmount;

      if(loan.isPaidOff) {
        badCreditList.remove(player.id);
      }
      print('✅ ${player.username} pagou o empréstimo ${loan.id} integralmente.');
    } else {
      print('⚠️ ${player.username} não tem crédito suficiente para pagar o empréstimo ${loan.id}.');
    }
  }

  void processRoundBonus(Player player) {
    player.receiveCredit(roundBonus, incomeTaxRate);
    player.roundBalance.bonusIn += roundBonus;
  }

// FUNÇÔES AUXILIAR: GESTÃO DAS AÇÔES E NEGOCIAÇÕES
  void buyFromIPO(Player buyer, String propertyId, int sharesAmount) {
    final totalCost = properties[propertyId]!.sharePrice * sharesAmount;
    
    if (buyer.currentCredit >= totalCost) {
      buyer.payDebit(totalCost);
      buyer.roundBalance.sharePurchasesOut += totalCost;

      properties[propertyId]!.availableShares -= sharesAmount;
      buyer.upgradePortfolio(propertyId, sharesAmount, totalCost);

      print('✅ ${buyer.username} adquiriu $sharesAmount ações de $propertyId por ${totalCost.toStringAsFixed(2)}');
    } else {
      print('⚠️ ${buyer.username} não tem crédito suficiente para adquirir ações de $propertyId.');
    }
  }

  void setTradeOffer(TradeOffer offer) {
    tradeOffers[offer.offerId] = offer;
  }
  
  void buyFromTrade(Player buyer, TradeOffer tradeOffer, Player? seller) {
    final offer = tradeOffers[tradeOffer.offerId];

    final totalCost = offer!.totalAskingPrice;
    final amount = offer.sharesAmount;
    final propertyId = offer.propertyId;

    buyer.payDebit(totalCost);
    buyer.roundBalance.sharePurchasesOut += totalCost;

    if(seller != null){
      seller.receiveCredit(totalCost, incomeTaxRate);
      seller.roundBalance.shareSalesIn += totalCost;
    }

    _transferShares(
      propertyId: propertyId,
      sharesAmount: amount,
      transactionPrice: totalCost,
      fromPlayer: seller,
      toPlayer: buyer,
    );
    
    // 4. FINALIZAÇÃO
    finishTradeOffer(tradeOffer.offerId);
  }

  void finishTradeOffer(String offerId){
    tradeOffers.remove(offerId);
  }
 
  void calculateDividendsToPay(Player player) {

    player.portfolio.forEach((propertyId, shareholderData) {
      final property = properties[propertyId];
      if (property != null) {
        _distributePayout(property, player);
        double netRetainedProfit = property.profitToRetain * (1.0 - propertyProfitTaxRate);
        property.applyValuation(netRetainedProfit);
      }
    });
    player.financialReport.dividendsReceived.add(player.roundBalance.dividendsIn);
  }

  void _distributePayout(Property property, Player player) {
    var shareholderData = player.portfolio[property.id]!;
    double dividendReceived = (property.distributableProfit / property.totalShares) * shareholderData.sharesOwned;
    
    player.receiveCredit(dividendReceived, incomeTaxRate); 
    player.roundBalance.dividendsIn += dividendReceived;
    print('${player.username} recebeu ${dividendReceived.toStringAsFixed(2)} da ${property.name}');
  }
  
  void _transferShares({
    required String propertyId,
    required int sharesAmount,
    required double transactionPrice,
    Player? fromPlayer,
    Player? toPlayer,
  }) {
    final property = properties[propertyId];
    var fromPortfolio = fromPlayer != null ? fromPlayer.portfolio : bankPortfolio;
    var toPortfolio = toPlayer != null ? toPlayer.portfolio : bankPortfolio;
    
    final fromShareholder = fromPortfolio[propertyId];

    if (fromShareholder == null || fromShareholder.sharesOwned < sharesAmount) {
      throw Exception("O remetente não tem $sharesAmount ações de ${property!.name} para transferir.");
    }

    // A. REMOÇÃO do Emissor (FROM)
    fromShareholder.sharesOwned -= sharesAmount;
    if (fromShareholder.sharesOwned == 0) {
      fromPortfolio.remove(propertyId);
    }

    // B. ADIÇÃO no Receptor (TO)
    if (toPortfolio.containsKey(propertyId)) {
      toPortfolio[propertyId]!.sharesOwned += sharesAmount;
    } else {
      toPortfolio[propertyId] = ShareHolder(
        playerId: toPlayer != null ? toPlayer.id : bankId,
        propertyId: propertyId,
        sharesOwned: sharesAmount,
        investmentValue: transactionPrice, 
      );
    }
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
  
  // FUNÇÔES AUXILIAR: GESTÃO DAS DÍVIDAS
  List<Loan> managePlayerLoans(Player player) {
    final foreclosuredLoans = List<Loan>.empty();
    if (player.loans.isEmpty) return foreclosuredLoans;

    for (var loan in player.loans) {
      if (loan.isPaidOff) continue;
      loan.reduceTerm(); 
      if (loan.roundsToPayOff <= -1) {
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
    final sharesToConfiscate = player.portfolio[property.id]?.sharesOwned ?? 0;
    
    if (sharesToConfiscate > 0) {
        _transferShares(
            propertyId: property.id, 
            sharesAmount: sharesToConfiscate,
            transactionPrice: 0,
            fromPlayer: player,
        );
        foreclosuredLoans.add(loan);
        print('🚫 ${player.username} perdeu ${property.name} por execução de hipoteca.');
    }
  }

  void _applyLateFee(Player player, Loan loan) {
    loan.totalDue *= (1.0 + lateFeeRate); // Aplica multa (lateFeeRate deve ser um atributo/constante)
    badCreditList[player.id] = player; // Adiciona à lista de mau crédito
    print('⚠️ ${player.username} sofreu multa no empréstimo ${loan.id}. Novo total: ${loan.totalDue.toStringAsFixed(2)}');
  }

// FUNÇÔES AUXILIAR: GESTÃO DE CONSTRUÇÔES
  void processBuildingPurchase(Player player, Property property, double buildingCost, double buildingRentIncrease, bool playerPayment) {
    if (player.currentCredit >= buildingCost && property.majorOwnerId == player.id) {
      if (playerPayment) {
        player.payDebit(buildingCost);
        player.roundBalance.buildingPurchasesOut += buildingCost;
      } else {
        player.roundBalance.buildingPurchasesOut += buildingCost;
        property.addBuilding(buildingRentIncrease, buildingCost);
      }
      print('🏗️ ${player.username} construiu em ${property.name} por ${buildingCost.toStringAsFixed(2)}');
    } else {
      print('⚠️ ${player.username} não tem crédito ou permissão suficiente para construir em ${property.name}.');
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