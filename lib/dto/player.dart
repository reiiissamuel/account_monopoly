
class Player {
  String peerId = "";
  String username = "";
  int receivedFrom = 0;
  int payedTo= 0;

  Player.empty();


  Player({required String peerId, required String username, required int receivedFrom, required int payedTo});

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
        peerId: map["peerId"] as String,
        username: map["username"] as String,
        receivedFrom: map["receivedFrom"] as int,
        payedTo: map["payedTo"] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "peerId": peerId,
      "username": username,
      "receivedFrom": receivedFrom,
      "payedTo": payedTo
    };
  }
}
