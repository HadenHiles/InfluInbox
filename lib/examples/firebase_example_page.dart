import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_services.dart';

/// Example usage of Firebase services in your Flutter app
class FirebaseExamplePage extends ConsumerStatefulWidget {
  const FirebaseExamplePage({super.key});

  @override
  ConsumerState<FirebaseExamplePage> createState() => _FirebaseExamplePageState();
}

class _FirebaseExamplePageState extends ConsumerState<FirebaseExamplePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _message = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Auth State Listener
            StreamBuilder(
              stream: FirebaseAuthService.authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text('Signed in as: ${snapshot.data?.email}'),
                          const SizedBox(height: 8),
                          ElevatedButton(onPressed: _signOut, child: const Text('Sign Out')),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(onPressed: _signIn, child: const Text('Sign In')),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(onPressed: _signUp, child: const Text('Sign Up')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            // Firestore Example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Firestore Example', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _writeToFirestore, child: const Text('Write to Firestore')),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _readFromFirestore, child: const Text('Read from Firestore')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cloud Functions Example
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Cloud Functions Example', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _callCloudFunction, child: const Text('Call Cloud Function')),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Message Display
            if (_message.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_message)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    try {
      await FirebaseAuthService.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);
      setState(() {
        _message = 'Successfully signed in!';
      });
    } catch (e) {
      setState(() {
        _message = 'Sign in failed: $e';
      });
    }
  }

  Future<void> _signUp() async {
    try {
      await FirebaseAuthService.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text);
      setState(() {
        _message = 'Successfully signed up!';
      });
    } catch (e) {
      setState(() {
        _message = 'Sign up failed: $e';
      });
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuthService.signOut();
      setState(() {
        _message = 'Successfully signed out!';
      });
    } catch (e) {
      setState(() {
        _message = 'Sign out failed: $e';
      });
    }
  }

  Future<void> _writeToFirestore() async {
    try {
      await FirestoreService.setDocument(path: 'test/example', data: {'message': 'Hello from Flutter!', 'timestamp': DateTime.now().toIso8601String(), 'user': FirebaseAuthService.currentUser?.email ?? 'anonymous'});
      setState(() {
        _message = 'Successfully wrote to Firestore!';
      });
    } catch (e) {
      setState(() {
        _message = 'Firestore write failed: $e';
      });
    }
  }

  Future<void> _readFromFirestore() async {
    try {
      final doc = await FirestoreService.getDocument(path: 'test/example');
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _message = 'Read from Firestore: ${data['message']} at ${data['timestamp']}';
        });
      } else {
        setState(() {
          _message = 'Document does not exist in Firestore';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Firestore read failed: $e';
      });
    }
  }

  Future<void> _callCloudFunction() async {
    try {
      final result = await FirebaseFunctionsService.callFunction(functionName: 'helloWorld', parameters: {'message': 'Hello from Flutter!'});
      setState(() {
        _message = 'Cloud Function result: ${result.data}';
      });
    } catch (e) {
      setState(() {
        _message = 'Cloud Function failed: $e';
      });
    }
  }
}
