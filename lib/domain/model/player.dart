
import 'package:account_monopoly/domain/model/balance.dart';
import 'package:account_monopoly/domain/model/financial_report.dart';
import 'package:account_monopoly/domain/model/mortgage.dart';
import 'package:account_monopoly/utils/string_utils.dart';

class Player {
  String id = "";
  String username = "";
  int receivedFrom = 0;
  int payedTo= 0;
  bool isHost = false;

  num currentCredit = 0;
  FinancialReport financialReport = FinancialReport.empty();
  Balance roundBalance = Balance.empty();
  List<Mortgage> mortgages = [];
  

  Player.empty();


  Player({required this.id, required this.username, required this.receivedFrom, required this.payedTo,
   required this.isHost, required currentCredit, required financialReport, required roundBalance, required mortgages});

  Player.of({required this.id, required this.username, required userModelId, required gameId, required this.isHost, required currentCredit}){
    id = "$username-$userModelId-${StringUtils.generateUUID(size: 5)}-$gameId";
  }

  Player.ofDefinedId({required String username, required id});

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
        id: map["id"] as String,
        username: map["username"] as String,
        receivedFrom: map["receivedFrom"] as int,
        payedTo: map["payedTo"] as int,
        isHost: map["isHost"] as bool,
        currentCredit: ["currentCredit"] as num,
        financialReport: FinancialReport.fromMap(map['financialReport']),
        roundBalance: FinancialReport.fromMap(map['roundBalance']),
        mortgages: (map['mortgages'] as List<dynamic>).map((h) => Mortgage.fromMap(h as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "receivedFrom": receivedFrom,
      "payedTo": payedTo,
      "isHost": isHost,
      'currentCredit': currentCredit,
      'financialReport': financialReport.toMap(),
      'roundBalance': roundBalance.toMap(),
      'mortgages': mortgages.map((mortgage) => mortgage.toMap()).toList(),
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
