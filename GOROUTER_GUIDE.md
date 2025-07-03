# GoRouter Configuration Documentation

This document explains the GoRouter setup for InfluInbox and how to use it effectively.

## 📁 Router Structure

The router configuration is located in `lib/config/router_config.dart` and provides:

- **Authentication-aware routing** with automatic redirects
- **Nested routes** for dashboard sections
- **Dynamic routes** with parameters
- **Error handling** with custom 404 page
- **Navigation extensions** for easier use

## 🛣️ Available Routes

### Main Routes

| Route | Name | Description |
|-------|------|-------------|
| `/` | `root` | Root route with auth redirect logic |
| `/auth` | `auth` | Authentication page |
| `/dashboard` | `dashboard` | Main dashboard |
| `/profile` | `profile` | User profile page |
| `/examples` | `examples` | Development examples list |

### Dashboard Sub-Routes

| Route | Name | Description |
|-------|------|-------------|
| `/dashboard/inbox` | `inbox` | Email inbox view |
| `/dashboard/analytics` | `analytics` | Analytics dashboard |
| `/dashboard/settings` | `settings` | App settings |

### Dynamic Routes

| Route | Name | Description |
|-------|------|-------------|
| `/email/:emailId` | `email_detail` | Email detail view with ID parameter |

### Example Routes

| Route | Name | Description |
|-------|------|-------------|
| `/examples/oauth` | `oauth_example` | OAuth testing page |
| `/examples/firebase` | `firebase_example` | Firebase testing page |

## 🔧 Configuration Features

### Authentication Redirect Logic

The router automatically handles authentication state:

```dart
redirect: (context, state) {
  final authState = ref.read(authStateProvider);
  final isOnAuthPage = state.uri.toString() == '/auth';
  
  return authState.when(
    data: (user) {
      // Redirect to dashboard if logged in but on auth page
      if (user != null && isOnAuthPage) {
        return '/dashboard';
      }
      // Redirect to auth if not logged in and accessing protected routes
      if (user == null && !isOnAuthPage && state.uri.toString() != '/') {
        return '/auth';
      }
      return null; // No redirect needed
    },
    loading: () => null, // Don't redirect while loading
    error: (_, __) => isOnAuthPage ? null : '/auth',
  );
},
```

### Error Handling

Custom 404 page with navigation back to home:

```dart
errorBuilder: (context, state) => Scaffold(
  appBar: AppBar(title: const Text('Page Not Found')),
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        Text('Page not found: ${state.uri}'),
        ElevatedButton(
          onPressed: () => context.go('/'),
          child: const Text('Go Home'),
        ),
      ],
    ),
  ),
),
```

## 📱 Usage Examples

### Basic Navigation

```dart
import 'package:go_router/go_router.dart';

// Navigate to a route
context.go('/dashboard');

// Navigate with replacement (no back button)
context.pushReplacement('/auth');

// Navigate with parameters
context.go('/email/123');

// Go back
context.pop();
```

### Using Named Routes

```dart
// Navigate using route names
context.goNamed('dashboard');
context.goNamed('email_detail', pathParameters: {'emailId': '123'});
```

### Using Navigation Extensions

The router includes helpful extensions:

```dart
import '../../config/router_config.dart';

// Use extension methods for common navigation
context.goToDashboard();
context.goToAuth();
context.goToEmailDetail('123');
context.goToProfile();
context.goToInbox();
context.goToAnalytics();
context.goToSettings();
```

### Navigation in Widgets

#### Button Navigation
```dart
ElevatedButton(
  onPressed: () => context.goToDashboard(),
  child: const Text('Go to Dashboard'),
)
```

#### List Item Navigation
```dart
ListTile(
  title: const Text('View Email'),
  onTap: () => context.goToEmailDetail(email.id),
)
```

#### Bottom Navigation
```dart
BottomNavigationBar(
  onTap: (index) {
    switch (index) {
      case 0:
        context.goToInbox();
        break;
      case 1:
        context.goToAnalytics();
        break;
      case 2:
        context.goToSettings();
        break;
    }
  },
  items: const [
    BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
    BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
  ],
)
```

## 🔒 Authentication Integration

### Automatic Redirects

The router automatically handles authentication state changes:

- **Logged out users** are redirected to `/auth`
- **Logged in users** on the auth page are redirected to `/dashboard`
- **Loading states** don't trigger redirects

### Provider Integration

The router uses the `authStateProvider` to check authentication status:

```dart
final authState = ref.read(authStateProvider);
```

## 🎯 Route Parameters

### Path Parameters

```dart
// Route definition
GoRoute(
  path: '/email/:emailId',
  name: 'email_detail',
  builder: (context, state) {
    final emailId = state.pathParameters['emailId']!;
    return EmailDetailPage(emailId: emailId);
  },
),

// Navigation
context.go('/email/123');
context.goNamed('email_detail', pathParameters: {'emailId': '123'});
```

### Query Parameters

```dart
// Navigate with query parameters
context.go('/dashboard?tab=inbox&filter=unread');

// Access query parameters
final tab = state.uri.queryParameters['tab'];
final filter = state.uri.queryParameters['filter'];
```

## 🛠️ Adding New Routes

### Simple Route

```dart
GoRoute(
  path: '/new-feature',
  name: 'new_feature',
  builder: (context, state) => const NewFeaturePage(),
),
```

### Nested Route

```dart
GoRoute(
  path: '/dashboard',
  name: 'dashboard',
  builder: (context, state) => const DashboardPage(),
  routes: [
    GoRoute(
      path: 'new-section',
      name: 'new_section',
      builder: (context, state) => const NewSectionPage(),
    ),
  ],
),
```

### Route with Parameters

```dart
GoRoute(
  path: '/user/:userId/profile',
  name: 'user_profile',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return UserProfilePage(userId: userId);
  },
),
```

## 🔍 Debugging

### Enable Debug Logging

```dart
GoRouter(
  debugLogDiagnostics: true, // Enable debug output
  // ... other configuration
)
```

### Check Current Route

```dart
final currentRoute = GoRouterState.of(context).uri.toString();
print('Current route: $currentRoute');
```

## 📚 Best Practices

### 1. Use Named Routes
```dart
// Good
context.goNamed('dashboard');

// Avoid
context.go('/dashboard');
```

### 2. Use Extension Methods
```dart
// Good
context.goToDashboard();

// Avoid
context.go('/dashboard');
```

### 3. Handle Parameters Safely
```dart
// Good
final emailId = state.pathParameters['emailId'];
if (emailId != null) {
  return EmailDetailPage(emailId: emailId);
}
return const ErrorPage();

// Avoid
final emailId = state.pathParameters['emailId']!; // Could crash
```

### 4. Check Authentication State
```dart
// The router handles this automatically, but for manual checks:
final user = ref.read(authStateProvider).value;
if (user == null) {
  context.goToAuth();
  return;
}
```

## 🔗 Related Files

- **Router Config**: `lib/config/router_config.dart`
- **Main App**: `lib/main.dart`
- **Auth Provider**: `lib/providers/auth_provider.dart`
- **Auth Page**: `lib/features/auth/auth_page.dart`
- **Dashboard**: `lib/features/dashboard/dashboard_page.dart`
