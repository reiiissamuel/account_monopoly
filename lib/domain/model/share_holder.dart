class ShareHolder {

  final String playerId;
  final String propertyId;
  double investmentValue;
  int sharesOwned;

  ShareHolder({
    required this.playerId,
    required this.propertyId,
    required this.sharesOwned,
    required this.investmentValue,
  });

  double get averageCostPerShare => investmentValue / sharesOwned;

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
