import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:flutter/material.dart';

class TradeOffer {
  final String offerId;
  final String sellerPlayerId;
  final String propertyId;
  final int sharesAmount;
  final double askingPrice;
  final OfferSource source;
  final double currentMarketPrice;
  final Color colorSignature;
  final String propertyName;

  TradeOffer({
    required this.offerId,
    required this.propertyId,
    required this.sellerPlayerId,
    required this.sharesAmount,
    required this.askingPrice,
    required this.source, 
    required this.currentMarketPrice, 
    required this.colorSignature, 
    required this.propertyName, 
  });

  // Cálculo de conveniência
  double get totalAskingPrice => sharesAmount * askingPrice;
}