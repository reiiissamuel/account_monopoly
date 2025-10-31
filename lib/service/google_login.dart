import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin {
  static final _googleSignIn = GoogleSignIn.instance;
  
  static const List<String> _scopes = <String>['email'];

  static Future<void> initialize() async {
    await _googleSignIn.initialize(
    );
  }

  static Future<GoogleSignInAccount?> login() async {

    try {
      // Usamos scopeHint para tentar combinar autenticação e autorização
      final account = await _googleSignIn.authenticate(
        scopeHint: _scopes,
      );
      
      return account;
    } on GoogleSignInException catch (e) {
      // Exemplo de tratamento de erro (usuário cancelou, etc.)
      print('Google Sign-In falhou: ${e.code.name}');
      return null;
    }
  }

  static Future<void> signout() => _googleSignIn.signOut();
}