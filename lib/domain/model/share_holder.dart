class ShareHolder {

  final String playerId;
  final String propertyId;
  double investmentValue;
  int sharesOwned;
  double dividendsReceived = 0;
  double saleCapitalGain = 0;

  ShareHolder({
    required this.playerId,
    required this.propertyId,
    required this.sharesOwned,
    required this.investmentValue,
    required this.saleCapitalGain
  });

  double get averageCostPerShare => (investmentValue - saleCapitalGain) / sharesOwned;

  double get totalInvested => averageCostPerShare * sharesOwned;

   //calcula lucro liquido
  double getNetProfit(double shareCurrentCost){
    return (portfolioValue(shareCurrentCost) + dividendsReceived) - totalInvested;
  }

   //cacula lucro liquido por acao
  double getNetProfitPerShare(double shareCurrentCost){
    if(sharesOwned == 0) return 0;
    return getNetProfit(shareCurrentCost) / sharesOwned;
  }

  //cacula porcentagem de lucro sobre custo
  double getProfitPercentage(double shareCurrentCost){
    return (((portfolioValue(shareCurrentCost) + dividendsReceived) / totalInvested) * 100) - 100;
  }

  //calculo de ganho de capital desconsiderando dividendos
  double getCapitalGain(double shareCurrentCost){
    return portfolioValue(shareCurrentCost) / totalInvested;
  }

  //calcula valor atual total dos ativos
  double portfolioValue(double shareCurrentCost){
    return  (sharesOwned * shareCurrentCost);
  }

  factory ShareHolder.fromMap(Map<String, dynamic> map) {
    return ShareHolder(
      playerId: map['playerId'] as String,
      propertyId: map['propertyId'] as String,
      sharesOwned: map['sharesOwned'] as int,
      investmentValue: map['investmentValue'] as double,
      saleCapitalGain: map['saleCapitalGain'] as double
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'propertyId': propertyId,
      'sharesOwned': sharesOwned,
      'investmentValue': investmentValue,
      'saleCapitalGain': saleCapitalGain
    };
  } 
}
