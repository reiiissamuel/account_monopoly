import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:flutter/material.dart';

class Property {
  final String id;
  final String name;
  final double basePrice;
  final int totalShares;
  final PropertyType propertyType;
  final Color colorSignature;

  String majorOwnerId;
  double currentPrice;
  int availableShares;
  double currentRent;
  double collectedRent = 0;
  double payoutPercentage;
  int buildings = 0;
  List<double> historicalPrices = [];
  List<double> historicalRents = [];

  Property.of({
    required this.id, 
    required this.name,
    required this.basePrice,
    required this.colorSignature,
    required this.totalShares, 
    required this.currentRent, 
    required this.payoutPercentage,
    required this.propertyType,
    required this.currentPrice,
    required this.availableShares,
    this.historicalPrices = const[],
    this.historicalRents = const[],
    this.collectedRent = 0,
    this.buildings = 0,
    this.majorOwnerId = "",
  });

  // GETTER: O preço da ação é SEMPRE calculado na hora (currentPrice / totalShares)
  double get sharePrice => currentPrice / totalShares;
  
  // GETTER: Retorna o lucro distribuível total (para o Ledger calcular)
  double get distributableProfit => collectedRent * payoutPercentage;
  
  // GETTER: Retorna o lucro a ser capitalizado (antes de multa)
  double get profitToRetain => collectedRent * (1.0 - payoutPercentage);

  void updateAvailableShares(int changeInShares) {
    availableShares += changeInShares;
  }

  void applyValuation(double netRetainedProfit) {
      currentPrice += netRetainedProfit; 
      _updateRent(netRetainedProfit);
      
      collectedRent = 0; 
      historicalPrices.add(currentPrice);
  }

  void _updateRent(double netRetainedProfit) {
    double valuationPercentage = netRetainedProfit / currentPrice; 
    currentRent *= (1.0 + valuationPercentage);
    historicalRents.add(currentRent);
  }

  void addBuilding(double buildingRentIncrease, double buildingCost) {
    buildings += 1;
    currentRent += buildingRentIncrease;
    currentPrice -= buildingCost;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'basePrice': basePrice,
      'majorOwnerId': majorOwnerId,
      'currentPrice': currentPrice,
      'colorSignature': colorSignature.toARGB32(),
      'totalShares': totalShares,
      'availableShares': availableShares,
      'currentRent': currentRent,
      'payoutPercentage': payoutPercentage,
      'propertyType': propertyType.toString(),
      'collectedRent': collectedRent,
      'buildings': buildings,
      'historicalPrices': historicalPrices,
      'historicalRents': historicalRents
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property.of(
        id: map['id'] as String,
        name: map['name'] as String,
        basePrice: map['basePrice'] as double,
        majorOwnerId: map['majorOwnerId'] as String,
        currentPrice: map['currentPrice'] as double,
        colorSignature: Color(map['colorSignature'] as int),
        totalShares: map['totalShares'] as int,
        availableShares: map['availableShares'] as int,
        currentRent: map['currentRent'] as double,
        payoutPercentage: map['payoutPercentage'] as double,
        collectedRent: map['collectedRent'] as double,
        buildings: map['buildings'] as int,
        historicalPrices: List<double>.from(map['historicalPrices'] as List<dynamic>),
        historicalRents: List<double>.from(map['historicalRents'] as List<dynamic>),
        propertyType: PropertyType.values.firstWhere((e) => e.toString() == map['propertyType']),
    );
  }
}