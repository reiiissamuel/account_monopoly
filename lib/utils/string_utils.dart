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

  static String unformatAsString(String input){
    return input.replaceAll("\$", "").replaceAll(".", "").replaceAll(",", "");
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

  static String generateAbrevCodeFromString(String value){
    if(value == null || value.isEmpty) throw Exception("Erro ao gerar codigo de abreviação da propriedade: Valor nulo ou vazio");
    final StringBuffer codeBuffer = StringBuffer();
    List<String> parts = value.toUpperCase().split(' ');
    switch (parts.length){
      case 1:
        codeBuffer.write(parts[0].substring(0, 4));
        break;
      case 2:
        codeBuffer.write(parts[0].substring(0,2));
        codeBuffer.write(parts[1].substring(0,2));
        break;
      case 3:
        codeBuffer.write(parts[0].substring(0,2));
        codeBuffer.write(parts[1][0]);
        codeBuffer.write(parts[2][0]);
        break;
      default:
        codeBuffer.write(parts[0][0]);
        codeBuffer.write(parts[1][0]);
        codeBuffer.write(parts[2][0]);
        codeBuffer.write(parts[3][0]);
    }
    return replaceDiacriticalMarks(codeBuffer.toString());
  }

  static String replaceDiacriticalMarks(String input) {
    const Map<String, String> replacements = {
      // A
      'Á': 'A', 'À': 'A', 'Ã': 'A', 'Ä': 'A', 'Â': 'A', 'Å': 'A', 'Ā': 'A',
      // E
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E', 'Ē': 'E',
      // I
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I', 'Ī': 'I',
      // O
      'Ó': 'O', 'Ò': 'O', 'Õ': 'O', 'Ö': 'O', 'Ô': 'O', 'Ø': 'O', 'Ō': 'O',
      // U
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U', 'Ū': 'U',
      // C
      'Ç': 'C',
      // N
      'Ñ': 'N',
      //
      'Ÿ': 'Y',
      // Símbolos Especiais (Ligaturas, etc.)
      'Æ': 'AE', 'Œ': 'OE', 'Þ': 'TH', 'Đ': 'D',
    };
    final StringBuffer buffer = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final String? replacement = replacements[char];
      if (replacement != null) {
        buffer.write(replacement);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}