import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_services.dart';

/// Provider for authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuthService.authStateChanges;
});

/// Provider for current user model
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(data: (user) => user != null ? UserModel.fromFirebaseUser(user) : null, loading: () => null, error: (_, __) => null);
});

/// Provider for authentication loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

/// Authentication service class
class AuthService {
  final Ref _ref;

  AuthService(this._ref);

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      final userCredential = await FirebaseAuthService.signInWithGoogle();
      if (userCredential?.user != null) {
        return UserModel.fromFirebaseUser(userCredential!.user!);
      }
      return null;
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Sign in with Microsoft
  Future<UserModel?> signInWithMicrosoft() async {
    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      final userCredential = await FirebaseAuthService.signInWithMicrosoft();
      if (userCredential?.user != null) {
        return UserModel.fromFirebaseUser(userCredential!.user!);
      }
      return null;
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      await FirebaseAuthService.signOut();
    } catch (e) {
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Get current user
  UserModel? get currentUser {
    return _ref.read(currentUserProvider);
  }

  /// Check if user is signed in
  bool get isSignedIn {
    return currentUser != null;
  }
}
