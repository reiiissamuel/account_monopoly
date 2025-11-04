import 'package:account_monopoly/domain/model/balance.dart';
import 'package:account_monopoly/domain/model/financial_report.dart';
import 'package:account_monopoly/domain/model/loan.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:account_monopoly/utils/string_utils.dart';

class Player {
  // 1. ATRIBUTOS IMUTÁVEIS (Definidos uma vez)
  final String id;
  final String username;
  
  bool isHost;
  
  // 2. ATRIBUTOS DE CONTROLE/RELATÓRIO IMUTÁVEIS (O objeto é final, mas o conteúdo é mutável)
  final Map<String, ShareHolder> portfolio; // Chave: propertyId
  final FinancialReport financialReport;
  final List<Loan> loans;

  // 3. ATRIBUTOS MUTÁVEIS (Estado que muda constantemente)
  double currentCredit;
  double incomeTax;
  double receivedFrom;
  double payedTo;
  Balance roundBalance;
  bool youWon = false;
  bool youBankrupt = false;

  // Construtor ÚNICO principal com todos os campos nomeados
  Player({
    required this.id, 
    required this.username, 
    required this.isHost,
    required this.currentCredit,
    required this.financialReport,
    required this.roundBalance,
    required this.loans,
    required this.portfolio,
    this.receivedFrom = 0.0, 
    this.payedTo = 0.0,
    this.incomeTax = 0.0,
    this.youBankrupt = false,
    this.youWon = false
  });

  Player.newGamePlayer({
    required String username, 
    required int userModelId, 
    required String gameId,
    required bool isHost,
    required double currentCredit,
  }) : this(
    id: "$username-$userModelId-${StringUtils.generateUUID(size: 5)}-$gameId",
    username: username,
    isHost: isHost,
    currentCredit: currentCredit,
    financialReport: FinancialReport.empty(),
    roundBalance: Balance.empty(),
    loans: [],
    portfolio: {},
    incomeTax: 0.0
  );

  Player.empty() : this(
    id: "",
    username: "",
    isHost: false,
    currentCredit: 0.0,
    incomeTax: 0.0,
    financialReport: FinancialReport.empty(),
    roundBalance: Balance.empty(),
    loans: [],
    portfolio: {},
  );
  
  factory Player.fromMap(Map<String, dynamic> map) {
    double credit = (map["currentCredit"] as num).toDouble();
    double incomeTax = (map["incomeTax"] as num? ?? 0).toDouble();
    double received = (map["receivedFrom"] as num? ?? 0).toDouble();
    double payed = (map["payedTo"] as num? ?? 0).toDouble();

    return Player(
      id: map["id"] as String,
      username: map["username"] as String,
      isHost: map["isHost"] as bool,
      currentCredit: credit,
      incomeTax: incomeTax,
      receivedFrom: received,
      payedTo: payed,
      financialReport: FinancialReport.fromMap(map['financialReport']),
      roundBalance: Balance.fromMap(map['roundBalance']),
      loans: (map['loans'] as List<dynamic>).map((h) => Loan.fromMap(h as Map<String, dynamic>)).toList(),
      portfolio: (map['portfolio'] as Map<String, dynamic>? ?? {}).map(
        (key, value) => MapEntry(key, ShareHolder.fromMap(value as Map<String, dynamic>)),
      ),
      youBankrupt: map['youBankrupt'] as bool? ?? false,
      youWon: map['youWon'] as bool? ?? false,
    );
  }
  
  void receiveCredit(double amount) {
    if (amount > 0) {
      currentCredit += amount;
    }
  }

  void payDebit(double amount) {
    if (amount > 0) {
      currentCredit -= amount;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "isHost": isHost,
      'currentCredit': currentCredit,
      'incomeTax': incomeTax,
      'receivedFrom': receivedFrom,
      'payedTo': payedTo,
      'financialReport': financialReport.toMap(),
      'roundBalance': roundBalance.toMap(),
      'loans': loans.map((loan) => loan.toMap()).toList(),
      'portfolio': portfolio.map((key, value) => MapEntry(key, value.toMap())),
      'youWon': youWon,
      'youBankrupt': youBankrupt,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

}

