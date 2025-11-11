import 'dart:math';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StringUtils extends TextInputFormatter{

  static String generateUUID({required int size}) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String result = '';

    for (int i = 0; i < size; i++) {
      result += chars[random.nextInt(chars.length)];
    }

    return result;
  }

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR', // Defina o locale desejado (ex: pt_BR para Real)
    symbol: '\$', // Símbolo da moeda
    decimalDigits: 2, // Número de casas decimais
  );

  static String currencyFormat(double input){
    return _currencyFormat.format(input);
  }

  static double currencyAsDouble(String input) {
    final num parsedValue = _currencyFormat.parse(input);
    return parsedValue.toDouble();
  }
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      // Impede a formatação se o campo estiver vazio (edge case)
      return newValue;
    }

    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    //dividindo por 100 para pegar os cents
    double value = double.parse(newValue.text) / 100;
    String formattedText = currencyFormat(value);

    // Retorna o novo valor do campo, ajustando a posição do cursor para o final
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}