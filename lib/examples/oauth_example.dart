import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_services.dart';
import '../config/oauth_config.dart';

/// Example page demonstrating OAuth authentication with Google and Microsoft
class OAuthExamplePage extends StatefulWidget {
  const OAuthExamplePage({Key? key}) : super(key: key);

  @override
  State<OAuthExamplePage> createState() => _OAuthExamplePageState();
}

class _OAuthExamplePageState extends State<OAuthExamplePage> {
  User? user;
  String? googleAccessToken;
  String? microsoftAccessToken;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuthService.currentUser;

    // Listen to auth state changes
    FirebaseAuthService.authStateChanges.listen((User? user) {
      setState(() {
        this.user = user;
      });
    });
  }

  Future<void> _signInWithGoogle() async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseAuthService.signInWithGoogle();
      if (userCredential != null) {
        // Get access token for Gmail API calls
        final token = await FirebaseAuthService.getGoogleAccessToken();
        setState(() {
          googleAccessToken = token;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully signed in with Google!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing in with Google: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _signInWithMicrosoft() async {
    setState(() => isLoading = true);
    try {
      final userCredential = await FirebaseAuthService.signInWithMicrosoft();
      if (userCredential != null) {
        // Get access token for Outlook API calls
        final token = await FirebaseAuthService.getMicrosoftAccessToken();
        setState(() {
          microsoftAccessToken = token;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully signed in with Microsoft!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing in with Microsoft: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => isLoading = true);
    try {
      await FirebaseAuthService.signOut();
      setState(() {
        googleAccessToken = null;
        microsoftAccessToken = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully signed out!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OAuth Authentication'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Authentication Status', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    if (user != null) ...[
                      Text('Signed in as: ${user!.email}'),
                      Text('Display Name: ${user!.displayName ?? 'N/A'}'),
                      Text('Provider: ${user!.providerData.map((p) => p.providerId).join(', ')}'),
                      if (user!.photoURL != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: CircleAvatar(backgroundImage: NetworkImage(user!.photoURL!), radius: 30),
                        ),
                    ] else ...[
                      const Text('Not signed in'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Authentication Buttons
            if (user == null) ...[
              ElevatedButton.icon(
                onPressed: isLoading ? null : _signInWithGoogle,
                icon: const Icon(Icons.email),
                label: const Text('Sign in with Google (Gmail)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              ),

              const SizedBox(height: 10),

              ElevatedButton.icon(
                onPressed: isLoading ? null : _signInWithMicrosoft,
                icon: const Icon(Icons.business),
                label: const Text('Sign in with Microsoft (Outlook)'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: isLoading ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ],

            const SizedBox(height: 20),

            // Access Token Info
            if (user != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Access Tokens', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      if (googleAccessToken != null) ...[const Text('Google Access Token:'), Text('${googleAccessToken!.substring(0, 20)}...', style: const TextStyle(fontFamily: 'monospace')), const SizedBox(height: 8)],
                      if (microsoftAccessToken != null) ...[
                        const Text('Microsoft Access Token:'),
                        Text('${microsoftAccessToken!.substring(0, 20)}...', style: const TextStyle(fontFamily: 'monospace')),
                        const SizedBox(height: 8),
                      ],
                      if (googleAccessToken == null && microsoftAccessToken == null) const Text('No access tokens available'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Gmail Features Limitation Warning
            if (OAuthConfig.isDevelopment) ...[
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Development Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        OAuthConfig.gmailLimitationMessage,
                        style: TextStyle(color: Colors.orange.shade800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current scopes: ${OAuthConfig.googleScopes.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],

            if (isLoading)
              const Center(
                child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
