import 'package:account_monopoly/enums/installment_type.dart';

import 'account.dart';

class Balance{
  int round = 0;
  int profit = 0;
  int expanses = 0;
  List<Account> accounts = [];

  num getRoundIncomming(int i){
    return accounts[i].bonus + accounts[i].qtdEventGain + accounts[i].restituicao + accounts[i].transferIn +
        accounts[i].mortgagesIn + accounts[i].otherReceives + accounts[i].loanIn + accounts[i].auctionIn;
  }

  num getRoundOutGoing(int i){
    return  accounts[i].previousAccountInstallment + accounts[i].loanInstallment + accounts[i].qtdPurchases +
        accounts[i].qtdEventPay + accounts[i].qtdHome + accounts[i].qtdHotel + accounts[i].ir + accounts[i].transferOut + accounts[i].otherPaymentsOut;
  }

  generateInstallments({required int installments, required int total, required InstallmentType type, required int tax}){
    int totalPlusTax = total + ((total * tax) / 100).floor();
    int installment = (totalPlusTax / installments).floor();

    for(int i = 1; i <= installments; i++){
      if(hasAccountInTheRound(round + i)) {
        type == InstallmentType.LOAN_INSTALLMENT
            ? accounts[round + i].loanInstallment += installment
            : accounts[round + i].previousAccountInstallment += installment;
      } else{
        Account newAccount = Account.empty();
        type == InstallmentType.LOAN_INSTALLMENT
            ? newAccount.loanInstallment = installment
            : newAccount.previousAccountInstallment = installment;
        newAccount.round = round + i;
        accounts.add(newAccount);
      }
    }
  }

  bool hasAccountInTheRound(int round) {
    for (var account in accounts) {
      if (account.round == round) {
        return true;
      }
    }
    return false;
  }

  void closeRoundAccount({required Account account}){
    if(hasAccountInTheRound(round)) {
      accounts[round] = account;
    } else {
      accounts.add(account);
    }
  }

  Account openRoundAccount(){
    Account account = Account.empty();
    if(hasAccountInTheRound(round + 1)) {
      account = accounts[round + 1];
    } else{
      account.round = round + 1;
    }
    return account;
  }


  Balance({required this.round, required this.profit, required this.expanses, required this.accounts});


  Balance.empty();

  Map<String, dynamic> toMap() {
    return {
      'round':  round,
      'profit': profit,
      'expanses': expanses,
      'accounts': accounts.map((account) => account.toMap()).toList()
    };
  }

  factory Balance.fromMap(Map<String, dynamic> map) {
    return Balance(
        round: map['round'] as int,
        profit: map['profit'] as int,
        expanses: map['expanses'] as int,
        accounts: (map['accounts'] as List<dynamic>).map((account) => Account.fromMap(account as Map<String, dynamic>)).toList()
    );
  }
}