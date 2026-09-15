import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service resmi untuk autentikasi pengguna menggunakan Firebase Auth dan Google Sign-In.
/// Mendukung multi-platform: Web (via popup) dan Mobile Android/iOS (via GoogleSignIn SDK).
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// Instance FirebaseAuth
  static FirebaseAuth get auth => _auth;

  /// Mendapatkan user Firebase yang sedang aktif
  static User? get currentFirebaseUser => _auth.currentUser;

  /// Stream status autentikasi Firebase
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Melakukan proses Sign In / Autentikasi dengan Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Platform Web: Menggunakan GoogleAuthProvider dengan Popup Firebase Auth
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        return await _auth.signInWithPopup(googleProvider);
      } else {
        // Platform Mobile (Android/iOS): Menggunakan google_sign_in native lalu link ke Firebase Auth
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // Pengguna membatalkan proses pemilihan akun
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } catch (e) {
      debugPrint('AuthService signInWithGoogle error: $e');
      rethrow;
    }
  }

  /// Keluar / Sign Out dari Firebase Auth dan Google Sign-In
  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService signOut error: $e');
    }
  }
}
