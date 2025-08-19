import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A minimal auth state provider exposing the raw Firebase [User] stream.
/// Use when only basic signed-in state or the User object is needed.
final basicAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});
