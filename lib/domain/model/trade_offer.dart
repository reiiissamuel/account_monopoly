class TradeOffer {
  final String offerId;
  final String sellerPlayerId;
  final String propertyId;
  final int sharesAmount;
  final double askingPrice;

  TradeOffer({
    required this.offerId,
    required this.sellerPlayerId,
    required this.propertyId,
    required this.sharesAmount,
    required this.askingPrice,
  });

  // Cálculo de conveniência
  double get totalAskingPrice => sharesAmount * askingPrice;
}