import 'package:account_monopoly/domain/model/balance.dart';

class FinancialReport {

  Map<int, Balance> historicalBalances;

  FinancialReport({
    required this.historicalBalances,
  });

  FinancialReport.empty():historicalBalances = {};

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
      // O Dart salva as chaves (int) corretamente
      'historicalBalances': historicalBalances.map((key, value) => MapEntry(key.toString(), value.toMap()))
      // Alterei key para key.toString() no toMap para garantir que o Firestore receba uma chave String,
      // evitando qualquer ambiguidade, embora o Firestore geralmente faça isso automaticamente.
    };
  }

  factory FinancialReport.fromMap(Map<String, dynamic> map) {
    // 1. O Map lido do banco VEM como Map<String, dynamic>.
    //    A chave (roundId) foi salva como string no banco de dados.
    final serializedBalances = map['historicalBalances'] as Map<String, dynamic>? ?? {};

    final Map<int, Balance> deserializedBalances = serializedBalances.map(
            (keyString, valueMap) {
          // 2. Converte a chave (String) de volta para int (roundId).
          //    O uso de int.tryParse garante que não haja falhas caso a chave não seja um número.
          final int roundId = int.tryParse(keyString) ?? 0;

          final Balance balance = Balance.fromMap(valueMap as Map<String, dynamic>);
          return MapEntry(roundId, balance);
        }
    );
    return FinancialReport(
      historicalBalances: deserializedBalances,
    );
  }
}