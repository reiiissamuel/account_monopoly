import 'package:account_monopoly/domain/enums/installment_type.dart';

import 'package:account_monopoly/domain/model/balance.dart';

class FinancialReport{
  int round = 0;
  int profit = 0;
  int expanses = 0;
  List<Balance> balances = [];

  num getRoundIncomming(int i){
    return balances[i].bonus + balances[i].qtdEventGain + balances[i].restituicao + balances[i].transferIn +
        balances[i].mortgagesIn + balances[i].otherReceives + balances[i].loanIn + balances[i].auctionIn;
  }

  num getRoundOutGoing(int i){
    return  balances[i].previousAccountInstallment + balances[i].loanInstallment + balances[i].qtdPurchases +
        balances[i].qtdEventPay + balances[i].qtdHome + balances[i].qtdHotel + balances[i].ir + balances[i].transferOut + balances[i].otherPaymentsOut;
  }

  void generateInstallments({required int installments, required int total, required InstallmentType type, required int tax}){
    int totalPlusTax = total + ((total * tax) / 100).floor();
    int installment = (totalPlusTax / installments).floor();

    for(int i = 1; i <= installments; i++){
      if(hasBalanceInTheRound(round + i)) {
        type == InstallmentType.LOAN_INSTALLMENT
            ? balances[round + i].loanInstallment += installment
            : balances[round + i].previousAccountInstallment += installment;
      } else{
        Balance newBalance = Balance.empty();
        type == InstallmentType.LOAN_INSTALLMENT
            ? newBalance.loanInstallment = installment
            : newBalance.previousAccountInstallment = installment;
        newBalance.round = round + i;
        balances.add(newBalance);
      }
    }
  }

  bool hasBalanceInTheRound(int round) {
    for (var account in balances) {
      if (account.round == round) {
        return true;
      }
    }
    return false;
  }

  void setNextRoundBalance(){
    Balance account = Balance.empty();
     if(hasBalanceInTheRound(round + 1)) {
      account = balances[round + 1];
    } else{
      account.round = round + 1;
      balances.add(account);
    }
  }


  FinancialReport({required this.round, required this.profit, required this.expanses, required this.balances});


  FinancialReport.empty();

  Map<String, dynamic> toMap() {
    return {
      'round':  round,
      'profit': profit,
      'expanses': expanses,
      'balances': balances.map((account) => account.toMap()).toList()
    };
  }

  factory FinancialReport.fromMap(Map<String, dynamic> map) {
    return FinancialReport(
        round: map['round'] as int,
        profit: map['profit'] as int,
        expanses: map['expanses'] as int,
        balances: (map['balances'] as List<dynamic>).map((account) => Balance.fromMap(account as Map<String, dynamic>)).toList()
    );
  }
}