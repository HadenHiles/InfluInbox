import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/firebase_services.dart';

/// Provider for authentication state - streams Firebase auth changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuthService.authStateChanges;
});

/// Provider for current user model - transforms Firebase User to UserModel
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(data: (user) => user != null ? UserModel.fromFirebaseUser(user) : null, loading: () => null, error: (_, __) => null);
});

/// Provider for authentication loading state
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(data: (user) => user != null, orElse: () => false);
});

/// Provider to check if auth is loading
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final manualLoading = ref.watch(authLoadingProvider);

  return authState.maybeWhen(loading: () => true, orElse: () => manualLoading);
});

/// Authentication service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

/// Provider for auth error state
final authErrorProvider = StateProvider<String?>((ref) => null);

/// Authentication service class
class AuthService {
  final Ref _ref;

  AuthService(this._ref);

  /// Clear any auth errors
  void clearError() {
    _ref.read(authErrorProvider.notifier).state = null;
  }

  /// Set auth error
  void _setError(String error) {
    _ref.read(authErrorProvider.notifier).state = error;
  }

  /// Sign in with Google
  Future<UserModel?> signInWithGoogle() async {
    clearError();
    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      final userCredential = await FirebaseAuthService.signInWithGoogle();
      if (userCredential?.user != null) {
        return UserModel.fromFirebaseUser(userCredential!.user!);
      }
      return null;
    } catch (e) {
      _setError('Failed to sign in with Google: ${e.toString()}');
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Sign in with Microsoft
  Future<UserModel?> signInWithMicrosoft() async {
    clearError();
    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      final userCredential = await FirebaseAuthService.signInWithMicrosoft();
      if (userCredential?.user != null) {
        return UserModel.fromFirebaseUser(userCredential!.user!);
      }
      return null;
    } catch (e) {
      _setError('Failed to sign in with Microsoft: ${e.toString()}');
      rethrow;
    } finally {
      _ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    clearError();
    _ref.read(authLoadingProvider.notifier).state = true;
    try {
      await FirebaseAuthService.signOut();
    } catch (e) {
      _setError('Failed to sign out: ${e.toString()}');
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

  /// Get current auth error
  String? get error {
    return _ref.read(authErrorProvider);
  }

  /// Check if currently loading
  bool get isLoading {
    return _ref.read(isAuthLoadingProvider);
  }
}
