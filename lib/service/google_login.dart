import 'package:google_sign_in/google_sign_in.dart';

class GoogleLogin {
  static final _googleSignIn = GoogleSignIn(
    scopes: <String>[
            'email',
        ]
  );
  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  static Future signout= _googleSignIn.signOut();
}