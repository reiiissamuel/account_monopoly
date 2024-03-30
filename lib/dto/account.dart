class Account{
  //dados reeferentes a fatura e pagamento posterior
  int round = 0;
  int previousAccoutInstallment = 0; //parcela de fatura anterior
  int loanInstallment = 0;
  int qtdPurchases = 0;
  int qtdEventPay = 0;
  int qtdHome = 0;
  int qtdHotel = 0;
  int qtdEventGain = 0;
  int bonus = 0;
  int ir = 0; //imposto de renda
  int restituicao = 0;
  bool isInInstallment = false; //retorna true se a fatura foi parcelada

  //dados somente para armazenamento todo ver possibilidade de usar dto separado
  int transferIn = 0;
  int transferOut = 0;
  int mortgagesIn = 0; //
  int otherReceives = 0;//
  int otherPaymentsOut = 0; //
  int loanIn = 0;  //
  int auctionIn = 0;


  Account(
      {
        required this.round,
        required this.previousAccoutInstallment,
        required this.loanInstallment,
        required this.qtdPurchases,
        required this.qtdEventPay,
        required this.qtdHome,
        required this.qtdHotel,
        required this.qtdEventGain,
        required this.bonus,
        required this.ir,
        required this.restituicao,
        required this.isInInstallment,
        required this.transferIn,
        required this.transferOut,
        required this.mortgagesIn,
        required this.otherReceives,
        required this.otherPaymentsOut,
        required this.loanIn,
        required this.auctionIn});

  Account.empty(); //valor de referencia para pagamento da fatura


  int getTotal(){
    return previousAccoutInstallment + loanInstallment + qtdPurchases + qtdEventPay + qtdHome + qtdHotel - qtdEventGain - bonus + ir - restituicao;
  }

  Map<String, dynamic> toMap() {
    return {
      'round':  round,
      'previousAccout': previousAccoutInstallment,
      'loanInstallment': loanInstallment,
      'qtdEventPay': qtdEventPay,
      'qtdHome': qtdHome,
      'qtdHotel':  qtdHotel,
      'qtdEventGain': qtdEventGain,
      'bonus': bonus,
      'ir': ir,
      'restituicao': restituicao,
      'isInInstallment':  isInInstallment,
      'transferIn': transferIn,
      'transferOut': transferOut,
      'mortgagesIn': mortgagesIn,
      'otherReceives':  otherReceives,
      'otherPaymentsOut': otherPaymentsOut,
      'loanIn': loanIn,
      'auctionIn': qtdEventPay,
      'qtdPurchases': qtdPurchases
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
        round: map['round'] as int,
        previousAccoutInstallment: map['previousAccoutInstallment'] as int,
        loanInstallment: map['loanInstallment'] as int,
        qtdEventPay: map['qtdEventPay'] as int,
        qtdHome: map['qtdHome']  as int,
        qtdHotel: map['qtdHotel']  as int,
        qtdEventGain: map['qtdEventGain'] as int,
        bonus: map['bonus'] as int,
        ir: map['ir'] as int,
        restituicao: map['restituicao'] as int,
        isInInstallment: map['isParcelada'] as bool,
        transferIn: map['transferIn']  as int,
        mortgagesIn: map['mortgagesIn']  as int,
        transferOut: map['transferOut'] as int,
        otherReceives: map['otherReceives'] as int,
        otherPaymentsOut: map['otherPaymentsOut']  as int,
        loanIn: map['loanIn'] as int,
        auctionIn: map['auctionIn']  as int,
        qtdPurchases: map['qtdPurchases']  as int
    );
  }


}


