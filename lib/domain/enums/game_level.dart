enum GameLevel{
  normal(description: "Normal", initalInterestRate: 0.05, propertyProfitTaxRate: 0.15, lateFeeRate: 0.05, incomeTaxRate: 0.2, propertyTax: 0.03),
  hard(description: "Difícil", initalInterestRate: 0.1, propertyProfitTaxRate: 0.25, lateFeeRate: 0.1, incomeTaxRate: 0.25, propertyTax: 0.05),
  veryHard(description: "Muito difícil", initalInterestRate: 0.15, propertyProfitTaxRate: 0.30, lateFeeRate: 0.15, incomeTaxRate: 0.3, propertyTax: 0.08);

  final String description;
  final double initalInterestRate;
  final double propertyProfitTaxRate;
  final double propertyTax;
  final double lateFeeRate;
  final double incomeTaxRate;

  const GameLevel({required this.description, required this.initalInterestRate, required this.propertyProfitTaxRate,
  required this.lateFeeRate, required this.incomeTaxRate, required this.propertyTax});
}