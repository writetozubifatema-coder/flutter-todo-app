import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Email/Password Login
  Future<UserCredential> loginWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  // ✅ Google Login
  Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();

    // optional: logout old session (helps sometimes)
    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception("Google Sign-In cancelled");
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }
}
