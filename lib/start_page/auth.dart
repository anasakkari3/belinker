import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';


class auth {
  final FirebaseAuth _Firebaseauth = FirebaseAuth.instance;
  User? get CurrentUser => _Firebaseauth.currentUser;
  Stream<User?> get authStateChanges => _Firebaseauth.authStateChanges();

  Future<void> signInWithEmailAndPassword ({
    required String email,
    required String password,
}) async {
    await _Firebaseauth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<void> createUserWithEmailAndPassword ({
    required String email,
    required String password,
  })   async {
    await _Firebaseauth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
  Future<void> signOut() async {
    await _Firebaseauth.signOut();
  }
  // ✅ Google Sign-In
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw Exception("Login cancelled by user");
    }

    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

 await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // ✅ Apple Sign-In
  Future<void> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

 await _Firebaseauth.signInWithCredential(oauthCredential);
  }
  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final OAuthCredential credential =
      FacebookAuthProvider.credential(result.accessToken!.token);
    await FirebaseAuth.instance.signInWithCredential(credential);
    } else {
      throw Exception("Facebook login failed: ${result.status}");
    }
  }


}