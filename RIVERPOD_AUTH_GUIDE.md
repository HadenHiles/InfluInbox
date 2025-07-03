# Riverpod Authentication Providers Guide

This guide explains the comprehensive Riverpod authentication system implemented in the InfluInbox Flutter application.

## Overview

The authentication system uses Flutter Riverpod for state management, providing reactive authentication state across the entire application with automatic UI updates and error handling.

## Core Providers

### 1. **authStateProvider** - Stream Provider

```dart
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuthService.authStateChanges;
});
```

- **Purpose**: Streams Firebase authentication state changes
- **Returns**: `AsyncValue<User?>` from Firebase Auth
- **Use**: Primary source of authentication state

### 2. **currentUserProvider** - Provider

```dart
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user != null ? UserModel.fromFirebaseUser(user) : null,
    loading: () => null,
    error: (_, __) => null,
  );
});
```

- **Purpose**: Transforms Firebase User to UserModel
- **Returns**: `UserModel?` or null
- **Use**: Access current user data in UI

### 3. **isAuthenticatedProvider** - Provider

```dart
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user != null,
    orElse: () => false,
  );
});
```

- **Purpose**: Simple boolean authentication check
- **Returns**: `bool` - true if authenticated
- **Use**: Conditional UI rendering and routing

### 4. **isAuthLoadingProvider** - Provider

```dart
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final manualLoading = ref.watch(authLoadingProvider);
  
  return authState.maybeWhen(
    loading: () => true,
    orElse: () => manualLoading,
  );
});
```

- **Purpose**: Combines Firebase auth loading with manual loading states
- **Returns**: `bool` - true if any auth operation is loading
- **Use**: Show loading indicators during auth operations

### 5. **authLoadingProvider** - State Provider

```dart
final authLoadingProvider = StateProvider<bool>((ref) => false);
```

- **Purpose**: Manual loading state for auth operations
- **Returns**: `bool` - controlled loading state
- **Use**: Internal state management for auth service

### 6. **authErrorProvider** - State Provider

```dart
final authErrorProvider = StateProvider<String?>((ref) => null);
```

- **Purpose**: Global authentication error state
- **Returns**: `String?` - error message or null
- **Use**: Display auth errors globally

### 7. **authServiceProvider** - Provider

```dart
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});
```

- **Purpose**: Provides AuthService instance with Riverpod integration
- **Returns**: `AuthService` instance
- **Use**: Perform authentication operations

## AuthService Class

The `AuthService` class provides methods for authentication operations with integrated Riverpod state management:

### Methods

#### **signInWithGoogle()**

```dart
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
```

#### **signInWithMicrosoft()**

```dart
Future<UserModel?> signInWithMicrosoft() async {
  // Similar implementation for Microsoft OAuth
}
```

#### **signOut()**

```dart
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
```

#### **Getters:**

- `currentUser` - Gets current `UserModel?`
- `isSignedIn` - Boolean check for authentication
- `error` - Current error message
- `isLoading` - Current loading state

#### **Utility Methods:**

- `clearError()` - Clears current error state
- `_setError(String error)` - Sets error state

## Usage Examples

### 1. **In Widgets - Check Authentication State**

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);
    
    if (isAuthenticated && currentUser != null) {
      return Text('Welcome, ${currentUser.name}!');
    } else {
      return Text('Please sign in');
    }
  }
}
```

### 2. **In Widgets - Show Loading State**

```dart
class AuthButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isAuthLoadingProvider);
    
    return ElevatedButton(
      onPressed: isLoading ? null : () async {
        final authService = ref.read(authServiceProvider);
        await authService.signInWithGoogle();
      },
      child: isLoading 
        ? CircularProgressIndicator() 
        : Text('Sign in with Google'),
    );
  }
}
```

### 3. **In Widgets - Handle Authentication**

```dart
class AuthWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        try {
          final authService = ref.read(authServiceProvider);
          await authService.signInWithGoogle();
          // Navigation handled by GoRouter automatically
        } catch (e) {
          // Error is handled globally via authErrorProvider
        }
      },
      child: Text('Sign in with Google'),
    );
  }
}
```

### 4. **Listen to Auth State Changes**

```dart
class AuthListener extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            print('User signed in: ${user.email}');
          } else {
            print('User signed out');
          }
        },
        loading: () => print('Auth loading...'),
        error: (error, _) => print('Auth error: $error'),
      );
    });
    
    return YourWidget();
  }
}
```

### 5. **Global Error Handling**

```dart
// In main.dart - global error listener
class InfluInboxApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      // ... other config
      builder: (context, child) {
        ref.listen<String?>(authErrorProvider, (previous, next) {
          if (next != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next),
                backgroundColor: Colors.red,
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () => ref.read(authServiceProvider).clearError(),
                ),
              ),
            );
          }
        });
        return child ?? SizedBox.shrink();
      },
    );
  }
}
```

## Router Integration

The authentication providers are integrated with GoRouter for automatic navigation:

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    redirect: (context, state) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      final isLoading = ref.read(isAuthLoadingProvider);
      
      if (isLoading) return null; // Don't redirect while loading
      
      if (isAuthenticated && state.uri.toString() == '/auth') {
        return '/dashboard'; // Redirect authenticated users from auth page
      }
      
      if (!isAuthenticated && state.uri.toString() != '/auth') {
        return '/auth'; // Redirect unauthenticated users to auth
      }
      
      return null; // No redirect needed
    },
    // ... routes
  );
});
```

## Best Practices

### 1. **Use Appropriate Providers**

- Use `isAuthenticatedProvider` for simple boolean checks
- Use `currentUserProvider` when you need user data
- Use `isAuthLoadingProvider` for loading states
- Use `authServiceProvider` for authentication operations

### 2. **Error Handling**

- Errors are handled globally via `authErrorProvider`
- Local error handling is optional
- Always check `mounted` when using context after async operations

### 3. **Performance**

- Providers automatically rebuild only necessary widgets
- Use `ref.read()` for one-time operations
- Use `ref.watch()` for reactive UI updates

### 4. **Testing**

```dart
// Override providers in tests
testWidgets('Auth test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
      ],
      child: MyApp(),
    ),
  );
});
```

## Integration Points

### 1. **Firebase Integration**

- Wraps `FirebaseAuthService` with Riverpod state management
- Maintains Firebase Auth as the source of truth
- Provides reactive updates to UI

### 2. **GoRouter Integration**

- Automatic redirects based on authentication state
- Route protection for authenticated/unauthenticated users
- Loading state management during navigation

### 3. **Global State Management**

- Centralized authentication state
- Automatic UI updates across the app
- Consistent error handling

## Migration from Direct Firebase Usage

If migrating from direct Firebase Auth usage:

### Before

```dart
// Direct Firebase usage
User? user = FirebaseAuth.instance.currentUser;
FirebaseAuth.instance.authStateChanges().listen((user) {
  // Handle state change
});
```

### After

```dart
// Riverpod usage
final isAuthenticated = ref.watch(isAuthenticatedProvider);
final currentUser = ref.watch(currentUserProvider);
```

## Conclusion

This Riverpod authentication system provides:

- ✅ **Reactive UI updates** when auth state changes
- ✅ **Centralized state management** across the app
- ✅ **Automatic error handling** with global display
- ✅ **Loading state management** for better UX
- ✅ **Router integration** for automatic navigation
- ✅ **Type-safe authentication** operations
- ✅ **Easy testing** with provider overrides

The system ensures consistent authentication behavior throughout the application while maintaining excellent developer experience and user experience.
