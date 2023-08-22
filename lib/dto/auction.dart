
class AuctionController{
  List<Auction> auctions = List.empty();
  Auction? auction;
  int currentPrice = 0;
  String? _currentWinner;

  AuctionController();

  void setNewAuction(Auction auction){
    this.auction = auction;
    currentPrice = auction.startValue;
  }

  payMinimmun(String currentWinner){
    currentPrice = auction!.startValue;
    _currentWinner = currentWinner;
  }

  raise(int value, String currentWinner){
    currentPrice = currentPrice += value;
    _currentWinner = currentWinner;
  }

  void endAuction(){
    auction!.endValue = currentPrice;
    auction!.buyer = _currentWinner!;
    auctions.add(auction!);
    auction = null;
    currentPrice = 0;
    _currentWinner = null;
  }

}

class Auction {

  int id;
  String auctionCaller;
  String propertyName;
  int startValue = 0;
  int endValue = 0;
  String buyer = "";


  Auction({required this.id, required this.auctionCaller, required this.propertyName, required this.startValue, required this.endValue});

  toMap() {
    return {
    "id": id,
    "auctionCaller": auctionCaller,
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
        endValue: map['endValue'] as int
    );}
}