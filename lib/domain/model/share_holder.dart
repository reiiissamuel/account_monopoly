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

  double get averageCostPerShare => sharesOwned == 0 ? 0.0 : (investmentValue - saleCapitalGain) / sharesOwned;

   //calcula lucro liquido
  double getNetProfit(double shareCurrentCost){
    return (portfolioValue(shareCurrentCost) + dividendsReceived) - investmentValue;
  }

   //cacula lucro liquido por acao
  double getNetProfitPerShare(double shareCurrentCost){
    if(sharesOwned == 0) return 0;
    return getNetProfit(shareCurrentCost) / sharesOwned;
  }

  //cacula porcentagem de lucro sobre custo
  double getProfitPercentage(double shareCurrentCost){
    return (((portfolioValue(shareCurrentCost) + dividendsReceived) / investmentValue) * 100) - 100;
  }

  //calculo de ganho de capital desconsiderando dividendos
  double getCapitalGain(double shareCurrentCost){
    return portfolioValue(shareCurrentCost) / investmentValue;
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
      investmentValue: (map['investmentValue'] as num).toDouble(),
      saleCapitalGain: (map['saleCapitalGain'] as num).toDouble()
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
