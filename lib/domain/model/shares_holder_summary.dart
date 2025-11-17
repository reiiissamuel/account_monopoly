
class SharesHolderSummary {

  final double totalPortfolioValue;
  final double totalInvested;
  final double totalDividends;

  double get totalNetProfit => totalDividends + totalPortfolioValue - totalInvested;
  double get totalGainCapital => totalPortfolioValue - totalInvested;

  SharesHolderSummary({required this.totalPortfolioValue, required this.totalInvested, required this.totalDividends});
}
