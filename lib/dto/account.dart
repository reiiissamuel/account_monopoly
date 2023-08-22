class Account{
  //dados reeferentes a fatura e pagamento posterior
  int round = 0;
  int previousAccout = 0; //parcela de fatura anterior
  int loanInstallment = 0;
  int qtdPurchases = 0;
  int qtdEventPay = 0;
  int qtdHome = 0;
  int qtdHotel = 0;
  int qtdEventGain = 0;
  int bonus = 0;
  int ir = 0; //imposto de renda
  int restituicao = 0;
  bool isParcelada = false; //retorna true se a fatura foi parcelada

  //dados somente para armazenamento todo ver possibilidade de usar dto separado
  int transferIn = 0;
  int transferOut = 0;
  int hipotecasIn = 0; //
  int otherReceives = 0;//
  int otherPaymentsOut = 0; //
  int loanIn = 0;  //
  int auctionIn = 0;


  Account(
      {
        required this.round,
        required this.previousAccout,
        required this.loanInstallment,
        required this.qtdPurchases,
        required this.qtdEventPay,
        required this.qtdHome,
        required this.qtdHotel,
        required this.qtdEventGain,
        required this.bonus,
        required this.ir,
        required this.restituicao,
        required this.isParcelada,
        required this.transferIn,
        required this.transferOut,
        required this.hipotecasIn,
        required this.otherReceives,
        required this.otherPaymentsOut,
        required this.loanIn,
        required this.auctionIn});

  Account.empty(); //valor de referencia para pagamento da fatura


  int getTotal(){
    return previousAccout + loanInstallment + qtdPurchases + qtdEventPay + qtdHome + qtdHotel - qtdEventGain - bonus + ir - restituicao;
  }

  Map<String, dynamic> toMap() {
    return {
      'round':  round,
      'previousAccout': previousAccout,
      'loanInstallment': loanInstallment,
      'qtdEventPay': qtdEventPay,
      'qtdHome': qtdHome,
      'qtdHotel':  qtdHotel,
      'qtdEventGain': qtdEventGain,
      'bonus': bonus,
      'ir': ir,
      'restituicao': restituicao,
      'isParcelada':  isParcelada,
      'transferIn': transferIn,
      'transferOut': transferOut,
      'hipotecasIn': hipotecasIn,
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
        previousAccout: map['previousAccout'] as int,
        loanInstallment: map['loanInstallment'] as int,
        qtdEventPay: map['qtdEventPay'] as int,
        qtdHome: map['qtdHome']  as int,
        qtdHotel: map['qtdHotel']  as int,
        qtdEventGain: map['qtdEventGain'] as int,
        bonus: map['bonus'] as int,
        ir: map['ir'] as int,
        restituicao: map['restituicao'] as int,
        isParcelada: map['isParcelada'] as bool,
        transferIn: map['transferIn']  as int,
        hipotecasIn: map['hipotecasIn']  as int,
        transferOut: map['transferOut'] as int,
        otherReceives: map['otherReceives'] as int,
        otherPaymentsOut: map['otherPaymentsOut']  as int,
        loanIn: map['loanIn'] as int,
        auctionIn: map['auctionIn']  as int,
        qtdPurchases: map['qtdPurchases']  as int
    );
  }


}


