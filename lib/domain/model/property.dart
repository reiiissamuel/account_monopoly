
import 'package:account_monopoly/domain/enums/property_type.dart';
import 'package:account_monopoly/utils/icon_data_extension.dart';
import 'package:flutter/material.dart';

class Property {
  final String id;
  final String name;
  final double basePrice;
  final PropertyType propertyType;
  final Color colorSignature;
  final Icon iconSignature;

  String majorOwnerId;
  double currentPrice;
  int totalShares;
  int availableShares;
  double currentRent;
  double collectedRent;
  double payoutPercentage;
  int buildings;
  List<double> historicalPrices;
  List<double> historicalRents;

  Property({
    required this.id, 
    required this.name,
    required this.basePrice,
    required this.colorSignature,
    required this.propertyType,
    required this.iconSignature,
    this.payoutPercentage = 0,
    this.currentRent = 0, 
    this.totalShares = 0, 
    this.currentPrice = 0.0,
    this.availableShares = 0,
    this.historicalPrices = const[],
    this.historicalRents = const[],
    this.collectedRent = 0,
    this.buildings = 0,
    this.majorOwnerId = "",
  }) {
    // Se currentPrice não foi definido, assumimos o basePrice como valor inicial
    if (currentPrice == 0.0) {
      currentPrice = basePrice;
    }
  }


  double get sharePrice => currentPrice / totalShares;

  double get distributableProfit => collectedRent * payoutPercentage;

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
      'historicalPrices': historicalPrices,
      'historicalRents': historicalRents,
      
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
        
        totalShares: map['totalShares'] as int,
        availableShares: map['availableShares'] as int,
        currentRent: map['currentRent'] is int ? (map['currentRent'] as int).toDouble() : map['currentRent'] as double,
        payoutPercentage: map['payoutPercentage'] is int ? (map['payoutPercentage'] as int).toDouble() : map['payoutPercentage'] as double,
        collectedRent: map['collectedRent'] is int ? (map['collectedRent'] as int).toDouble() : map['collectedRent'] as double,
        buildings: map['buildings'] as int,
 
        historicalPrices: List<double>.from(map['historicalPrices'] as List<dynamic>).map((e) => e is int ? e.toDouble() : e).toList(),
        historicalRents: List<double>.from(map['historicalRents'] as List<dynamic>).map((e) => e is int ? e.toDouble() : e).toList(),

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
}