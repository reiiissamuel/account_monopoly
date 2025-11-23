import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/exception/domain_exception.dart';
import 'package:account_monopoly/utils/configs_constants.dart';
import 'package:account_monopoly/utils/icon_data_extension.dart';
import 'package:flutter/material.dart';

class Property {
  final String id;
  final String name;
  final double basePrice;
  final PropertyType propertyType;
  final Color colorSignature;
  final Icon iconSignature;

  int lastDividendRound;
  double currentPrice;
  double currentRent;
  double currentBuildingCost;
  String majorOwnerId;
  int totalShares;
  double payoutPercentage;
  int availableShares;
  double collectedRent;
  int buildings;
  List<double> historicalSharesPrices = List.empty(growable: true);
  List<double> historicalRents = List.empty(growable: true);
  List<double> historicalDividends = List.empty(growable: true);

  Property({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.colorSignature,
    required this.propertyType,
    required this.iconSignature,
    required this.currentBuildingCost,
    this.payoutPercentage = ConfigsConstants.initialPayout,
    this.currentRent = 0,
    this.totalShares = 0,
    this.currentPrice = 0.0,
    this.availableShares = 0,
    this.collectedRent = 0,
    this.buildings = 0,
    this.majorOwnerId = "",
    this.lastDividendRound = 0,
  }) {
    if (currentPrice == 0.0) {
      currentPrice = basePrice;
    }
  }

  void _setHistoricalData(List<double> rents, List<double> dividends, List<double> sharesPrice){
    this.historicalSharesPrices = sharesPrice;
    this.historicalRents = rents;
    this.historicalDividends = dividends;
  }

  double get sharePrice => currentPrice / totalShares;

  double get distributableProfit => collectedRent * payoutPercentage;

  double get profitToRetain => collectedRent - distributableProfit;

  double get currentDividendsPerShare => distributableProfit / totalShares;

  void updateAvailableShares(int changeInShares) {
    availableShares += changeInShares;
  }

  void applyValuation(double netRetainedProfit, int referenceRound) {
    _updateHistoriacalData();
    currentPrice += netRetainedProfit;
    _updateRent(netRetainedProfit);

    collectedRent = 0;
  }

  void _updateRent(double netRetainedProfit) {
    double valuationPercentage = netRetainedProfit / currentPrice;
    currentRent *= (1.0 + valuationPercentage);
  }

  void _updateHistoriacalData() {
    historicalSharesPrices.add(sharePrice);
    historicalRents.add(currentRent);
    historicalDividends.add(currentDividendsPerShare);
  }

  void addBuilding(
    double buildingRentIncrease,
    int amountBuildings,
    double markupUsage,
  ) {
    if (amountBuildings + buildings > ConfigsConstants.maxBuildings) {
      throw MaxBuildingsException(ConfigsConstants.maxBuildingsErrorMsg);
    }
    buildings += amountBuildings;
    currentRent = buildingRentIncrease > currentRent
        ? buildingRentIncrease
        : currentRent;
    currentPrice -= markupUsage;
  }

  void checkIfEnoughMarkup(double value) {
    if (currentPrice < value) {
      throw NotEnoughMarkUPException(ConfigsConstants.notEnoughMarkupErrorMsg);
    }
  }

  Map<String, dynamic> toMap() {
    // ⚠️ Pegamos o IconData da propriedade 'icon' do widget Icon.
    final IconData? iconData = iconSignature.icon;

    if (iconData == null) {
      throw StateError(
        "A propriedade 'iconSignature' não contém IconData para serialização.",
      );
    }

    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'majorOwnerId': majorOwnerId,
      'currentPrice': currentPrice,
      'colorSignature': colorSignature.toARGB32(), // Usa extensão
      'totalShares': totalShares,
      'availableShares': availableShares,
      'currentRent': currentRent,
      'payoutPercentage': payoutPercentage,
      'propertyType': propertyType.name,
      'collectedRent': collectedRent,
      'buildings': buildings,
      'historicalSharesPrices': historicalSharesPrices,
      'historicalRents': historicalRents,
      'historicalDividends': historicalDividends,
      'currentBuildingCost': currentBuildingCost,
      'lastDividendRound': lastDividendRound,

      // ✅ SERIALIZAÇÃO DO ÍCONE: Converte o IconData para Map.
      'iconSignature': iconData.toMap(),
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {

    // 2. Constrói o widget Icon final
    // OBS: É altamente recomendado armazenar apenas o IconData, não o widget Icon, na classe de modelo.
    final Icon restoredIcon = Icon(IconDataExtension.fromMap(
      map['iconSignature'] as Map<String, dynamic>,
    ));
    var rents = List<double>.from((map['historicalRents'] as List<dynamic>).map((e) => e.toDouble()).toList(), growable: true);
    var dividends = List<double>.from((map['historicalDividends'] as List<dynamic>).map((e) => e.toDouble()).toList(), growable: true);
    var sharesPrices = List<double>.from((map['historicalSharesPrices'] as List<dynamic>).map((e) => e.toDouble()).toList(), growable: true);
    Property property = Property(
        id: map['id'] as String,
        name: map['name'] as String,

        propertyType: PropertyType.values.firstWhere((t) => t.name == map['propertyType'] as String),
        basePrice: (map['basePrice'] as num).toDouble(),
        currentPrice: (map['currentPrice'] as num).toDouble(),
        currentRent: (map['currentRent'] as num).toDouble(),
        payoutPercentage: (map['payoutPercentage'] as num).toDouble(),
        collectedRent: (map['collectedRent'] as num).toDouble(),
        currentBuildingCost: (map['currentBuildingCost'] as num).toDouble(),
        majorOwnerId: map['majorOwnerId'] as String,
        colorSignature: Color(map['colorSignature'] as int),
        iconSignature: restoredIcon,

        lastDividendRound: map['lastDividendRound'] != null ? (map['lastDividendRound'] as num).toInt() : 0,
        totalShares: map['totalShares'] as int,
        availableShares: map['availableShares'] as int,
        buildings: map['buildings'] as int
    );
    property._setHistoricalData(rents, dividends, sharesPrices);
    return property;
  }

  Property copyWith({
    int? totalShares,
    int? availableShares,
    // Inclua todos os outros campos aqui
  }) {
    return Property(
      id: id,
      name: name,
      basePrice: basePrice,
      colorSignature: colorSignature,
      propertyType: propertyType,
      iconSignature: iconSignature,
      currentBuildingCost: currentBuildingCost,
      totalShares: totalShares ?? this.totalShares,
      availableShares: availableShares ?? this.availableShares,
      currentRent: currentRent,
    );
  }
}
