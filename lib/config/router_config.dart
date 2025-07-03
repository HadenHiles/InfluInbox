import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/auth_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../examples/oauth_example.dart';
import '../examples/firebase_example_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/common_widgets.dart';

/// Router configuration for the app
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Auth routes
      GoRoute(path: '/auth', name: 'auth', builder: (context, state) => const AuthPage()),

      // Main app routes
      GoRoute(
        path: '/',
        name: 'root',
        redirect: (context, state) {
          // Check authentication state and redirect accordingly
          final authState = ref.read(authStateProvider);
          return authState.when(
            data: (user) => user != null ? '/dashboard' : '/auth',
            loading: () => null, // Stay on current route while loading
            error: (_, __) => '/auth',
          );
        },
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),

      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
        routes: [
          // Dashboard sub-routes
          GoRoute(path: 'inbox', name: 'inbox', builder: (context, state) => const _InboxPage()),
          GoRoute(path: 'analytics', name: 'analytics', builder: (context, state) => const _AnalyticsPage()),
          GoRoute(path: 'settings', name: 'settings', builder: (context, state) => const _SettingsPage()),
        ],
      ),

      // Example routes (for development)
      GoRoute(
        path: '/examples',
        name: 'examples',
        builder: (context, state) => const _ExamplesListPage(),
        routes: [
          GoRoute(path: '/oauth', name: 'oauth_example', builder: (context, state) => const OAuthExamplePage()),
          GoRoute(path: '/firebase', name: 'firebase_example', builder: (context, state) => const FirebaseExamplePage()),
        ],
      ),

      // Email detail route with dynamic parameter
      GoRoute(
        path: '/email/:emailId',
        name: 'email_detail',
        builder: (context, state) {
          final emailId = state.pathParameters['emailId']!;
          return _EmailDetailPage(emailId: emailId);
        },
      ),

      // Profile route
      GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const _ProfilePage()),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go('/'), child: const Text('Go Home')),
          ],
        ),
      ),
    ),

    // Redirect logic for authentication
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isOnAuthPage = state.uri.toString() == '/auth';

      return authState.when(
        data: (user) {
          // If user is logged in but on auth page, redirect to dashboard
          if (user != null && isOnAuthPage) {
            return '/dashboard';
          }
          // If user is not logged in and not on auth page, redirect to auth
          if (user == null && !isOnAuthPage && state.uri.toString() != '/') {
            return '/auth';
          }
          return null; // No redirect needed
        },
        loading: () => null, // Don't redirect while loading
        error: (_, __) => isOnAuthPage ? null : '/auth',
      );
    },
  );
});

// Placeholder pages for demonstration
class _InboxPage extends StatelessWidget {
  const _InboxPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: const EmptyStateWidget(title: 'Inbox', subtitle: 'Your emails will appear here', icon: Icons.inbox),
    );
  }
}

class _AnalyticsPage extends StatelessWidget {
  const _AnalyticsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: const EmptyStateWidget(title: 'Analytics', subtitle: 'Email analytics and insights', icon: Icons.analytics),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const EmptyStateWidget(title: 'Settings', subtitle: 'App preferences and configuration', icon: Icons.settings),
    );
  }
}

class _ExamplesListPage extends StatelessWidget {
  const _ExamplesListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(leading: const Icon(Icons.security), title: const Text('OAuth Example'), subtitle: const Text('Test Google and Microsoft authentication'), onTap: () => context.go('/examples/oauth')),
          ),
          Card(
            child: ListTile(leading: const Icon(Icons.cloud), title: const Text('Firebase Example'), subtitle: const Text('Test Firebase services'), onTap: () => context.go('/examples/firebase')),
          ),
        ],
      ),
    );
  }
}

class _EmailDetailPage extends StatelessWidget {
  final String emailId;

  const _EmailDetailPage({required this.emailId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Detail'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email, size: 64),
            const SizedBox(height: 16),
            Text('Email ID: $emailId', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.pop(), child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const EmptyStateWidget(title: 'Profile', subtitle: 'User profile and account settings', icon: Icons.person),
    );
  }
}

// Extension for easier navigation
extension GoRouterExtension on BuildContext {
  /// Navigate to dashboard
  void goToDashboard() => go('/dashboard');

  /// Navigate to auth page
  void goToAuth() => go('/auth');

  /// Navigate to email detail
  void goToEmailDetail(String emailId) => go('/email/$emailId');

  /// Navigate to profile
  void goToProfile() => go('/profile');

  /// Navigate to inbox
  void goToInbox() => go('/dashboard/inbox');

  /// Navigate to analytics
  void goToAnalytics() => go('/dashboard/analytics');

  /// Navigate to settings
  void goToSettings() => go('/dashboard/settings');
}
