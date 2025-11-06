import 'package:account_monopoly/domain/enums/loan_type.dart';

class Loan {
  final String id;
  final LoanType type;
  final double principalBorrowed; 
  final String? collateralId;
  double totalDue; 
  double principalPaid = 0.0;
  int roundsToPayOff;
  
  Loan({
    required this.id,
    required this.type,
    required this.totalDue,
    required this.principalBorrowed,
    this.collateralId,
    required this.roundsToPayOff,
  });

  // GETTER: Retorna o saldo devedor
  double get remainingDebt => totalDue - principalPaid;

  // GETTER: Checa se a dívida foi totalmente paga
  bool get isPaidOff => remainingDebt <= 0;

  // Método para amortizar
  void applyPayment(double paymentAmount) {
      if (paymentAmount > remainingDebt) {
          principalPaid = totalDue; // Paga o que falta
      } else {
          principalPaid += paymentAmount;
      }
  }
  // Método para reduzir o prazo
  void reduceTerm() {
      roundsToPayOff -= 1;
  }
  
  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'type': type.toString(),
      'totalDue': totalDue,
      'principalBorrowed': principalBorrowed,
      'collateralId': collateralId,
      'principalPaid': principalPaid,
      'roundsToPayOff': roundsToPayOff
    };
  }

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] as String,
      type: LoanType.values.firstWhere((e) => e.toString() == map['type']),
      totalDue: map['totalDue'] as double,
      principalBorrowed: map['principalBorrowed'] as double,
      collateralId: map['collateralId'] as String?,
      roundsToPayOff: map['roundsToPayOff'] as int,
    )..principalPaid = map['principalPaid'] as double;
  }

}