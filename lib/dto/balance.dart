import 'account.dart';

class Balance{
  int round = 0;
  int profit = 0;
  int expanses = 0;
  List<Account> accounts = [];

  num getRoundIncomming(int i){
    return accounts[i].bonus + accounts[i].qtdEventGain + accounts[i].restituicao + accounts[i].transferIn +
        accounts[i].hipotecasIn + accounts[i].otherReceives + accounts[i].loanIn + accounts[i].auctionIn;
  }

  num getRoundOutGoing(int i){
    return  accounts[i].previousAccout + accounts[i].loanInstallment + accounts[i].qtdPurchases +
        accounts[i].qtdEventPay + accounts[i].qtdHome + accounts[i].qtdHotel + accounts[i].ir + accounts[i].transferOut + accounts[i].otherPaymentsOut;
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