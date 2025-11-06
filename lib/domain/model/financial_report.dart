
import 'package:account_monopoly/domain/model/balance.dart';

class FinancialReport {
  
  final Map<int, Balance> historicalBalances;
  final List<double> dividendsReceived = [];

  FinancialReport({
    required this.historicalBalances
  });

  FinancialReport.empty() : historicalBalances = {};

  double get totalIncome {
    return historicalBalances.values.fold(0.0, (sum, balance) => sum + balance.roundIncomes);
  }

  double get totalExpenses {
    return historicalBalances.values.fold(0.0, (sum, balance) => sum + balance.roundOutcomes);
  }
  
  double get netProfit => totalIncome - totalExpenses;

  
  void addRoundBalance(int roundId, Balance completedRoundBalance) {
    if (historicalBalances.containsKey(roundId)) {
      throw Exception("Tentativa de adicionar o balanço da rodada $roundId duas vezes.");
    }
    historicalBalances[roundId] = completedRoundBalance;
  }
  
  Balance? getBalanceByRound(int roundId) {
      return historicalBalances[roundId];
  }

  Map<String, dynamic> toMap() {
    return {
      // Serializa o Map diretamente (chave: string, valor: toMap())
      'historicalBalances': historicalBalances.map((key, value) => MapEntry(key, value.toMap()))
    };
  }

  factory FinancialReport.fromMap(Map<String, dynamic> map) {
        final serializedBalances = map['historicalBalances'] as Map<String, dynamic>? ?? {};
        final Map<int, Balance> deserializedBalances = serializedBalances.map(
            (keyString, valueMap) {
                final int roundId = int.parse(keyString); 
                final Balance balance = Balance.fromMap(valueMap as Map<String, dynamic>);
                return MapEntry(roundId, balance);
            }
        );
        return FinancialReport(
            historicalBalances: deserializedBalances,
        );
    }
}