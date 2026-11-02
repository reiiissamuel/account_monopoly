import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:flutter/material.dart';

class TradeOffer {
  final String offerId;
  final String sellerPlayerId;
  final String sellerName;
  final String propertyId;
  final int sharesAmount;
  final double askingPrice;
  final OfferSource source;
  final double currentMarketPrice;
  final Color colorSignature;
  final String propertyName;
  int turnsToEnd;

  TradeOffer({
    required this.offerId,
    required this.propertyId,
    required this.sellerPlayerId,
    required this.sellerName,
    required this.sharesAmount,
    required this.askingPrice,
    required this.source, 
    required this.currentMarketPrice, 
    required this.colorSignature, 
    required this.propertyName,
    required this.turnsToEnd
  });

  // Cálculo de conveniência
  double get totalAskingPrice => sharesAmount * askingPrice;

  Map<String, dynamic> toMap() {
  return {
    'offerId': offerId,
    'sellerPlayerId': sellerPlayerId,
    'sellerName': sellerName,
    'propertyId': propertyId,
    'sharesAmount': sharesAmount,
    'askingPrice': askingPrice,
    'source': source.name,
    'currentMarketPrice': currentMarketPrice,
    'colorSignature': colorSignature.toARGB32(),
    'propertyName': propertyName,
    'turnsToEnd': turnsToEnd,
  };
  }

  factory TradeOffer.fromMap(Map<String, dynamic> map) {
    return TradeOffer(
      offerId: map['offerId'] as String,
      sellerPlayerId: map['sellerPlayerId'] as String,
      sellerName: map['sellerName'] as String,
      propertyId: map['propertyId'] as String,
      sharesAmount: map['sharesAmount'] as int,
      askingPrice: (map['askingPrice'] as num).toDouble(),
      source: OfferSource.values.firstWhere((e) => e.name == map['source']),
      currentMarketPrice: (map['currentMarketPrice'] as num).toDouble(),
      colorSignature: Color(map['colorSignature'] as int),
      propertyName: map['propertyName'] as String,
      turnsToEnd: map['turnsToEnd'] as int,
    );
  }
}