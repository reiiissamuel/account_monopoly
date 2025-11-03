import 'package:account_monopoly/domain/enums/property_type.dart';

class Property {
  final String id;
  final String name;
  final double baseValue;
  final int totalShares;
  PropertyType propertyType;
  
  double currentValue;
  double sharePrice;
  int availableShares;
  double currentRent;
  double payoutPercentage;

  Property.of({
    required this.id, 
    required this.name, 
    required this.currentValue,
    required this.totalShares, 
    required this.availableShares, 
    required this.currentRent, 
    required this.payoutPercentage,
    required this.propertyType
  }) : baseValue = currentValue,
       sharePrice = currentValue / totalShares;
}