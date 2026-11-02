import 'package:flutter/material.dart';

extension IconDataExtension on IconData {
  // Em vez de serializar propriedades brutas, mapeie para uma chave/string
  String toKey() {
    if (this == Icons.local_shipping) return 'local_shipping';
    if (this == Icons.local_taxi) return 'local_taxi';
    if (this == Icons.train) return 'train';
    if (this == Icons.directions_bus) return 'directions_bus';
    if (this == Icons.nature) return 'nature';
    if (this == Icons.bolt) return 'bolt';
    if (this == Icons.local_gas_station) return 'local_gas_station';
    if (this == Icons.account_balance) return 'account_balance';
    if (this == Icons.airplanemode_active) return 'airplanemode_active';
    if (this == Icons.water) return 'water';
    if (this == Icons.phone) return 'phone';
    // Adicione aqui os ícones que o seu jogo utiliza
    return 'default';
  }

  static IconData fromKey(String key) {
    switch (key) {
      case 'local_shipping':
        return Icons.local_shipping;
      case 'local_taxi':
        return Icons.local_taxi;
      case 'train':
        return Icons.train;
      case 'directions_bus':
        return Icons.directions_bus;
      case 'nature':
        return Icons.nature;
      case 'bolt':
        return Icons.bolt;
      case 'local_gas_station':
        return Icons.local_gas_station;
      case 'account_balance':
        return Icons.account_balance;
      case 'airplanemode_active':
        return Icons.airplanemode_active;
      case 'water':
        return Icons.water;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.business;
    }
  }
}