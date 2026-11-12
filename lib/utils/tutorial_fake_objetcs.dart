import 'package:account_monopoly/domain/enums/offer_type.dart';
import 'package:account_monopoly/domain/model/financial_report.dart';
import 'package:account_monopoly/domain/model/balance.dart';
import 'package:account_monopoly/domain/model/property.dart';
import 'package:account_monopoly/domain/model/trade_offer.dart';
import 'package:account_monopoly/domain/model/share_holder.dart';
import 'package:flutter/material.dart';
import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/domain/model/player.dart';

abstract final class TutorialFakeObjects {

  TutorialFakeObjects._();

  static final Property _fakeProperty = Property(
      id: "FAKE_PROPERTY",
      name: "Propriedade A",
      propertyType: PropertyType.stocks, basePrice: 200,
      colorSignature: Colors.grey.toARGB32(),
      currentBuildingCost: 200,
      iconSignature: 'iconSignature',
    );

  static final TradeOffer fakeTradeOffer = TradeOffer(
        offerId: "FAKE_PROPERTY",
        propertyName: "Propriedade A",
        colorSignature: Colors.grey.toARGB32(),
        currentMarketPrice: 16,
        askingPrice: 16,
        propertyId: "FAKE_OFFER",
        sellerName: "property",
        sellerPlayerId: "property",
        turnsToEnd: 1, sharesAmount: 1000, source: OfferSource.fundIPO,
      );
  
  static final ShareHolder fakeShareHolder = ShareHolder(
      playerId: "player",
      propertyId: "FAKE_PROPERTY",
      sharesOwned: 100,
      investmentValue: 1000,
      saleCapitalGain: 100,
    );

  static final Player fakePlayer = Player(
      id: "player",
      username: "Jogador A",
      currentCredit: 180,
      financialReport: FinancialReport.empty(),
      roundBalance: Balance.empty(),
      loans: [],
     portfolio: {},
    );

  static Property getFakeProperty() {
    _fakeProperty.collectedRent = 45;
    return _fakeProperty;
  }

}