
class Auction {

  int id;
  String auctionCaller;
  String propertyName;
  int currentValue;
  int startValue = 0;
  int endValue = 0;
  late List<Map<String, bool>> whichPlayersIdStillIn;
  String buyer = "";


  Auction({required this.id, required this.auctionCaller, required this.propertyName, required this.startValue, required this.endValue, required this.currentValue});

  void setFinalValue() {
    endValue = currentValue;
  }

  bool areTherePlayersIn(){
    return whichPlayersIdStillIn.where((e) => e.containsValue(true)).length >= 2;
  }

  toMap() {
    return {
    "id": id,
    "auctionCaller": auctionCaller,
    "currentValue": currentValue,
    "propertyName": propertyName,
    "startValue": startValue,
    "endValue": endValue
  };
  }

  factory Auction.fromMap(Map<String, dynamic> map) {
    return Auction(
      id: map['id'] as int,
      auctionCaller: map['auctionCaller'] as String,
      propertyName: map['propertyName'] as String,
      startValue: map['startValue'] as int,
      endValue: map['endValue'] as int,
      currentValue: map['currentValue'] as int
    );}

}