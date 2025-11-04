
import 'package:account_monopoly/domain/enums/loan_type.dart';
import 'package:account_monopoly/domain/model/loan.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/domain/model/player.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';

class Ledger {
  final Map<String, Property> properties; 

  double currentInterestRate;
  double propertyProfitTaxRate;
  double lateFeeRate = 0.05;
  Map<String, Player> badCreditList = {};
  final Map<String, TradeOffer> tradeOffers;
  
  final Map<String, ShareHolder> bankPortfolio = {}; // ações adiquirdas pelo banco através de execuções hipotecárias
  
  Ledger({
    required this.properties,
    required this.currentInterestRate,
    required this.propertyProfitTaxRate,
    this.tradeOffers = const {},
  });

  Ledger.empty() : 
    properties = {},
    currentInterestRate = 0.05,
    propertyProfitTaxRate = 0.15,
    tradeOffers = {};

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

  void processLoanPayment(Player player, Loan loan, double paymentAmount) {
    if (player.currentCredit >= paymentAmount && paymentAmount <= loan.totalDue) {
      player.payDebit(paymentAmount);
      player.roundBalance.otherOut += loan.totalDue;
      loan.principalPaid += paymentAmount;
      if(loan.isPaidOff) {
        badCreditList.remove(player.id);
        loan.finishLoan();
      }
      print('✅ ${player.username} pagou o empréstimo ${loan.id} integralmente.');
    } else {
      print('⚠️ ${player.username} não tem crédito suficiente para pagar o empréstimo ${loan.id}.');
    }
  }

  void processRoundBonus(Player player, double bonusAmount) {
    player.receiveCredit(bonusAmount);
    player.roundBalance.bonusIn += bonusAmount;
  }

// FUNÇÔES AUXILIAR: GESTÃO DAS AÇÔES E NEGOCIAÇÕES
  void newTradeOffer({
    required Player seller,
    required String propertyId,
    required int amount,
    required double askingPrice,
    required String offerId
  }) {

    final newOffer = TradeOffer(
      offerId: offerId,
      sellerPlayerId: seller.id,
      propertyId: propertyId,
      sharesAmount: amount,
      askingPrice: askingPrice
    );

    tradeOffers[offerId] = newOffer;
  }
  
  void processTrade({
    required Player buyer,
    required String offerId,
    required Player seller
  }) {
    final offer = tradeOffers[offerId];

    final totalCost = offer!.totalAskingPrice;
    final amount = offer.sharesAmount;
    final propertyId = offer.propertyId;

    buyer.payDebit(totalCost);
    seller.receiveCredit(totalCost);
    seller.roundBalance.shareSalesIn += totalCost;
    buyer.roundBalance.sharePurchasesOut += totalCost;

    _transferShares(
      propertyId: propertyId,
      sharesAmount: amount,
      transactionPrice: totalCost,
      fromPlayer: seller,
      toPlayer: buyer,
    );
    
    // 4. FINALIZAÇÃO
    tradeOffers.remove(offerId);
  }
 
  void closeRoundAccounting(Player player) {

    player.portfolio.forEach((propertyId, shareholderData) {
      final property = properties[propertyId];
      if (property != null) {
        _distributePayout(property, player);
        double netRetainedProfit = property.profitToRetain * (1.0 - propertyProfitTaxRate);
        property.applyValuation(netRetainedProfit);
      }
    });

    _managePlayerLoans(player);
    _checkForMajorOwner(player);
  }

  void _distributePayout(Property property, Player player) {
    var shareholderData = player.portfolio[property.id]!;
    double dividendReceived = (property.distributableProfit / property.totalShares) * shareholderData.sharesOwned;
    
    player.receiveCredit(dividendReceived); 
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
        playerId: toPlayer != null ? toPlayer.id : "bank",
        propertyId: propertyId,
        sharesOwned: sharesAmount,
        investmentValue: transactionPrice, 
      );
    }
  }

  void _checkForMajorOwner(Player player) {
    player.portfolio.forEach((propertyId, shareholderData) {
      final property = properties[propertyId];
      if (property == null) return;
      
      if (shareholderData.sharesOwned > property.totalShares / 2 && property.majorOwnerId != player.id) {
        property.majorOwnerId = player.id;
      } else if (property.majorOwnerId == player.id) {
        property.majorOwnerId = "";
      }
    });
  }
  
  // FUNÇÔES AUXILIAR: GESTÃO DAS DÍVIDAS
  void _managePlayerLoans(Player player) {
    if (player.loans.isEmpty) return;
    _processPlayerLoanState(player);
    player.loans.removeWhere((loan) => loan.isPaidOff);
  }

  void _processPlayerLoanState(Player player) {
    for (int i = player.loans.length - 1; i >= 0; i--) {
      var loan = player.loans[i];
      
      if (loan.isPaidOff) continue;
      
      loan.reduceTerm(); 

      if (loan.roundsToPayOff <= -1) {
        _handleLoanDefault(player, loan);
      }
      
      _handleLoanLate(player, loan);
    }
  }

  void _handleLoanDefault(Player player, Loan loan) {
    if (loan.type == LoanType.mortgage && loan.collateralId != null) {
      _executeMortgage(player, loan);
    } else if (loan.type == LoanType.bankLoan) {
      _applyLateFee(player, loan);
    }
  }

  void _handleLoanLate(Player player, Loan loan) {
    // Esta lógica foi simplificada para ser executada em um ponto específico

    if (loan.roundsToPayOff <= -3) {
      if (player.currentCredit >= loan.totalDue) {
        player.payDebit(loan.totalDue);
        player.roundBalance.otherOut += loan.totalDue;
        loan.finishLoan();
        badCreditList.remove(player.id);
        print('✅ ${player.username} teve o empréstimo ${loan.id} pago forçadamente.');
      } else {
        player.youBankrupt = true;
        print('❌ ${player.username} está em falência e não pode cobrir o empréstimo ${loan.id}.');
      }
    }
  }

  void _executeMortgage(Player player, Loan loan) {
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
        loan.finishLoan(); 
        print('🚫 ${player.username} perdeu ${property.name} por execução de hipoteca.');
    }
  }

  void _applyLateFee(Player player, Loan loan) {
    loan.totalDue *= (1.0 + lateFeeRate); // Aplica multa (lateFeeRate deve ser um atributo/constante)
    badCreditList[player.id] = player; // Adiciona à lista de mau crédito
    print('⚠️ ${player.username} sofreu multa no empréstimo ${loan.id}. Novo total: ${loan.totalDue.toStringAsFixed(2)}');
  }


// FUNÇÔES AUXILIAR: GESTÃO DE CONSTRUÇÔES
  void processBuildingPurchase(Player player, Property property, double buildingCost, double buildingRentIncrease) {
    if (player.currentCredit >= buildingCost && property.majorOwnerId == player.id) {
      player.payDebit(buildingCost);
      player.roundBalance.buildingPurchasesOut += buildingCost;
      property.addBuilding(buildingRentIncrease, buildingCost);
      print('🏗️ ${player.username} construiu em ${property.name} por ${buildingCost.toStringAsFixed(2)}');
    } else {
      print('⚠️ ${player.username} não tem crédito ou permissão suficiente para construir em ${property.name}.');
    }
  }
}