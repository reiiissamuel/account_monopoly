import 'dart:math';

class StringUtils {

  StringUtils ();

  String currencyFormat(String ns){
    String s = ns.replaceAll(".", "");

    //[1.000 10.000 100.000] [1.000.000 10.000.000 100.000.000]
    if(s.length == 4 || s.length == 5 || s.length == 6)
      return s.substring(0, s.length - 3) + "." + s.substring(s.length - 3 , s.length);
    else if(s.length == 7 || s.length == 8 || s.length == 9)
      return s.substring(0, s.length - 6) + "." + s.substring(s.length - 6, s.length - 3) + "." + s.substring(s.length - 3 , s.length);
    else
      return s;
  }

  String generateUUID({required int size}) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    String result = '';

    for (int i = 0; i < size; i++) {
      result += chars[random.nextInt(chars.length)];
    }

    return result;
  }
}