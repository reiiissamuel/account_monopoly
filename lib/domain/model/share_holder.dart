class ShareHolder {

  final String playerId;
  final String propertyId;
  double investmentValue;
  int sharesOwned;
  double dividendsReceived = 0;

  ShareHolder({
    required this.playerId,
    required this.propertyId,
    required this.sharesOwned,
    required this.investmentValue,
  });

  double get averageCostPerShare => investmentValue / sharesOwned;

  double getNetProfit(double shareCurrentCost){
    return (sharesOwned * shareCurrentCost) + dividendsReceived - investmentValue;
  }

  double getNetProfitPerShare(double shareCurrentCost){
    return getNetProfit(shareCurrentCost) / sharesOwned;
  }

  double getProfitPercentage(double shareCurrentCost){
    return ((((sharesOwned * shareCurrentCost) + dividendsReceived) / investmentValue) * 100) - 100;
  }

  factory ShareHolder.fromMap(Map<String, dynamic> map) {
    return ShareHolder(
      playerId: map['playerId'] as String,
      propertyId: map['propertyId'] as String,
      sharesOwned: map['sharesOwned'] as int,
      investmentValue: map['investmentValue'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'playerId': playerId,
      'propertyId': propertyId,
      'sharesOwned': sharesOwned,
      'investmentValue': investmentValue,
    };
  } 
}
