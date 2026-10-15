import 'package:flutter/material.dart';

extension IconDataExtension on IconData {
  Map<String, dynamic> toMap() {
    return {
      'codePoint': codePoint,
      if (fontFamily != null) 'fontFamily': fontFamily,
      if (fontPackage != null) 'fontPackage': fontPackage, 
    };
  }

  static IconData fromMap(Map<String, dynamic> map) {
    return IconData(
      map['codePoint'] as int,
      fontFamily: map['fontFamily'] as String?,
      fontPackage: map['fontPackage'] as String?,
    );
  }
}

// -------------------------------------------------------------------
// 2. EXTENSÃO PARA COLOR (SERIALIZAÇÃO DA COR)
// -------------------------------------------------------------------
extension ColorExtension on Color {
  int toARGB32() => value;
  }