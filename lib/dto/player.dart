
import 'package:account_monopoly/utils/string_utils.dart';

class Player {
  String id = "";
  String username = "";
  int receivedFrom = 0;
  int payedTo= 0;
  bool isHost = false;

  Player.empty();


  Player({required this.id, required this.username, required this.receivedFrom, required this.payedTo, required this.isHost});

  Player.of({required this.id, required this.username, required userModelId, required gameId, required this.isHost}){
    id = "$username-$userModelId-${StringUtils.generateUUID(size: 5)}-$gameId";
  }

  Player.ofDefinedId({required String username, required id});

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
        id: map["id"] as String,
        username: map["username"] as String,
        receivedFrom: map["receivedFrom"] as int,
        payedTo: map["payedTo"] as int,
        isHost: map["isHost"] as bool
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "receivedFrom": receivedFrom,
      "payedTo": payedTo,
      "isHost": isHost
    };
  }

  @override
  bool equals(Player other) {
    if (identical(this, other)) return true;

    return other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
