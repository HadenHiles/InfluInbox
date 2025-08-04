import 'package:go_router/go_router.dart';
import 'features/intro/intro_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/theme/theme_screen.dart';
import 'features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', name: 'intro', builder: (context, state) => const IntroScreen()),
    GoRoute(path: '/login', name: 'login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/dashboard', name: 'dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(path: '/theme', name: 'theme', builder: (context, state) => const ThemeScreen()),
    GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsScreen()),
  ],
);
