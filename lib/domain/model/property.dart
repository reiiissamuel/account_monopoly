
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

  int lastUpdateRound;
  double currentPrice;
  double currentRent;
  double currentBuildingCost;
  String majorOwnerId;
  int totalShares;
  double payoutPercentage;
  int availableShares;
  double collectedRent;
  int buildings;
  List<double> historicalSharesPrices;
  List<double> historicalRents;
  List<double> historicalDividends;

  Property({
    required this.id, 
    required this.name,
    required this.basePrice,
    required this.colorSignature,
    required this.propertyType,
    required this.iconSignature,
    required this.currentBuildingCost,
    this.payoutPercentage = 0.3,
    this.currentRent = 0, 
    this.totalShares = 0, 
    this.currentPrice = 0.0,
    this.availableShares = 0,
    List<double>? historicalSharesPrices,
    List<double>? historicalRents,
    List<double>? historicalDividends,
    this.collectedRent = 0,
    this.buildings = 0,
    this.majorOwnerId = "",
    this.lastUpdateRound = 0
  }) : historicalSharesPrices = <double>[], historicalRents =  <double>[], historicalDividends = <double>[] {
    if (currentPrice == 0.0) {
      currentPrice = basePrice;
    }
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
    lastUpdateRound = referenceRound;
  }

  void _updateRent(double netRetainedProfit) {
    double valuationPercentage = netRetainedProfit / currentPrice ;
    currentRent *= (1.0 + valuationPercentage);
  }

  void _updateHistoriacalData(){
    historicalSharesPrices.add(sharePrice);
    historicalRents.add(currentRent);
    historicalDividends.add(currentDividendsPerShare);

  }

  void addBuilding(double buildingRentIncrease, int amountBuildings, double markupUsage) {
    if (amountBuildings + buildings > ConfigsConstants.maxBuildings) throw MaxBuildingsException(ConfigsConstants.maxBuildingsErrorMsg);
    buildings += amountBuildings;
    currentRent = buildingRentIncrease > currentRent ? buildingRentIncrease : currentRent;
    currentPrice -= markupUsage;
  }

  void checkIfEnoughMarkup(double value){
    if (currentPrice < value) throw NotEnoughMarkUPException(ConfigsConstants.notEnoughMarkupErrorMsg);
  }

Map<String, dynamic> toMap() {
    // ⚠️ Pegamos o IconData da propriedade 'icon' do widget Icon.
    final IconData? iconData = iconSignature.icon; 
    
    if (iconData == null) {
      throw StateError("A propriedade 'iconSignature' não contém IconData para serialização.");
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
      'propertyType': propertyType.toString(),
      'collectedRent': collectedRent,
      'buildings': buildings,
      'historicalSharesPrices': historicalSharesPrices,
      'historicalRents': historicalRents,
      'historicalDividends': historicalDividends,
      'currentBuildingCost': currentBuildingCost,
      'lastDividendRound': lastUpdateRound,
      
      // ✅ SERIALIZAÇÃO DO ÍCONE: Converte o IconData para Map.
      'iconSignature': iconData.toMap(), 
    };
  }

 factory Property.fromMap(Map<String, dynamic> map) {
    
    // 1. Recria o IconData a partir do Map serializado.
    final IconData restoredIconData = IconDataExtension.fromMap(
      map['iconSignature'] as Map<String, dynamic>
    );

    // 2. ✅ Constrói o widget Icon final para o construtor Property.
    // OBS: Estilos como color/size devem ser aplicados no widget de visualização, não aqui.
    final Icon restoredIcon = Icon(restoredIconData);

    return Property(
        id: map['id'] as String,
        name: map['name'] as String,
        basePrice: map['basePrice'] is int ? (map['basePrice'] as int).toDouble() : map['basePrice'] as double,
        majorOwnerId: map['majorOwnerId'] as String,
        currentPrice: map['currentPrice'] is int ? (map['currentPrice'] as int).toDouble() : map['currentPrice'] as double,

        colorSignature: Color(map['colorSignature'] as int),
        iconSignature: restoredIcon,

        lastUpdateRound: map['lastUpdateRound'] != null ? map['lastUpdateRound'] as int : 0,
        totalShares: map['totalShares'] as int,
        availableShares: map['availableShares'] as int,
        currentRent: map['currentRent'] is int ? (map['currentRent'] as int).toDouble() : map['currentRent'] as double,
        payoutPercentage: map['payoutPercentage'] is int ? (map['payoutPercentage'] as int).toDouble() : map['payoutPercentage'] as double,
        collectedRent: map['collectedRent'] is int ? (map['collectedRent'] as int).toDouble() : map['collectedRent'] as double,
        buildings: map['buildings'] as int,
        currentBuildingCost: map['currentBuildingCost'] as double,

        historicalRents: List<double>.from(map['historicalRents'] as List<dynamic>).map((e) => e is int ? e.toDouble() : e).toList(),
        historicalDividends: map['historicalDividends'] != null
            ? List<double>.from(map['historicalDividends'] as List<dynamic>).map((e) => e is int ? e.toDouble() : e).toList()
            : <double>[],
        historicalSharesPrices: map['historicalSharesPrices'] != null
            ? List<double>.from(map['historicalSharesPrices'] as List<dynamic>).map((e) => e is int ? e.toDouble() : e).toList()
            : <double>[],

        propertyType: PropertyType.values.firstWhere((e) => e.toString() == map['propertyType']),
    );
  }

  @override
  bool operator ==(Object other) {
    // Verifica se 'other' é do mesmo tipo e não nulo
    if (identical(this, other)) return true; // Se for a mesma instância, são iguais.
    // Acessa as propriedades (id, name, etc.) para fazer a comparação de valor.
    return other is Property &&
        other.runtimeType == runtimeType &&
        other.id == id; // Critério de Igualdade: O ID deve ser igual.
  }

  // 2. Override do hashCode
  @override
  int get hashCode => id.hashCode; // Gera o hash baseado no 

  Property copyWith({
    int? totalShares,
    int? availableShares,
    // Inclua todos os outros campos aqui
  }) {
    return Property(id: id, name: name, basePrice: basePrice, colorSignature: colorSignature, propertyType: propertyType,
     iconSignature: iconSignature, currentBuildingCost: currentBuildingCost, totalShares: totalShares ?? this.totalShares,
      availableShares: availableShares ?? this.availableShares, currentRent: currentRent);
  }
}