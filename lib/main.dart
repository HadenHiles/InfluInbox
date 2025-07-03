import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firebase_services.dart';
import 'config/router_config.dart';
import 'providers/auth_provider.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for all platforms
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firestore settings
  FirebaseServices.configureFirestore();

  // Initialize Firebase App Check (optional, for production apps)
  // await FirebaseServices.initializeAppCheck();

  // Initialize Firebase Messaging (optional, for push notifications)
  // await FirebaseServices.initializeMessaging();

  runApp(const ProviderScope(child: InfluInboxApp()));
}

class InfluInboxApp extends ConsumerWidget {
  const InfluInboxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: _buildTheme(),
      routerConfig: router,
      builder: (context, child) {
        return AuthErrorListener(child: child ?? const SizedBox.shrink());
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: Colors.blue,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
      cardTheme: const CardThemeData(elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12.0)))),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius)),
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: AppConstants.smallPadding),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius)),
        contentPadding: const EdgeInsets.all(AppConstants.defaultPadding),
      ),
    );
  }
}

/// Widget that listens to auth errors and displays them globally
class AuthErrorListener extends ConsumerWidget {
  final Widget child;

  const AuthErrorListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth errors and show them
    ref.listen<String?>(authErrorProvider, (previous, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next),
                backgroundColor: Colors.red,
                action: SnackBarAction(label: 'Dismiss', textColor: Colors.white, onPressed: () => ref.read(authServiceProvider).clearError()),
              ),
            );
          }
        });
      }
    });

    return child;
  }
}
