import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_services.dart';
import '../../config/oauth_config.dart';

/// Authentication page with Google and Microsoft OAuth
class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  bool isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuthService.signInWithGoogle();
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing in: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _signInWithMicrosoft() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuthService.signInWithMicrosoft();
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing in: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo and Title
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.inbox, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text('InfluInbox', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Manage your emails efficiently', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600])),
                ],
              ),

              const SizedBox(height: 48),

              // Development Mode Warning
              if (OAuthConfig.isDevelopment) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Development Mode',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(OAuthConfig.gmailLimitationMessage, style: TextStyle(color: Colors.orange.shade800)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Sign In Buttons
              ElevatedButton.icon(
                onPressed: isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.email),
                label: const Text('Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: isLoading ? null : _signInWithMicrosoft,
                icon: const Icon(Icons.business),
                label: const Text('Continue with Microsoft'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              if (isLoading) ...[const SizedBox(height: 24), const Center(child: CircularProgressIndicator())],
            ],
          ),
        ),
      ),
    );
  }
}
