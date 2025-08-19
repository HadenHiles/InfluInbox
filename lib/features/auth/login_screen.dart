import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_services.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegister = true; // Start in create account mode

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;
    ref.read(authLoadingProvider.notifier).state = true;
    var success = false;
    try {
      if (_isRegister) {
        await FirebaseAuthService.createUserWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
      } else {
        await FirebaseAuthService.signInWithEmailAndPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());
      }
      success = true;
    } catch (e) {
      ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
    if (!mounted) return;
    if (success) context.go('/dashboard');
  }

  Future<void> _signInGoogle() async {
    await ref.read(authServiceProvider).signInWithGoogle();
    if (!mounted) return;
    if (ref.read(isAuthenticatedProvider)) context.go('/dashboard');
  }

  Future<void> _signInMicrosoft() async {
    await ref.read(authServiceProvider).signInWithMicrosoft();
    if (!mounted) return;
    if (ref.read(isAuthenticatedProvider)) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isAuthLoadingProvider);
    final error = ref.watch(authErrorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Welcome to InfluInbox', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (v) {
                          final value = v ?? '';
                          if (!_isRegister) {
                            // Sign in: enforce Firebase minimum (6 chars) only
                            return value.length >= 6 ? null : 'Password must be at least 6 characters.';
                          }
                          // Registration: stronger policy
                          if (value.length < 8) return 'Use at least 8 characters.';
                          final hasUpper = value.contains(RegExp(r'[A-Z]'));
                          final hasLower = value.contains(RegExp(r'[a-z]'));
                          final hasDigit = value.contains(RegExp(r'\d'));
                          final hasSpecial = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));
                          if (hasUpper && hasLower && hasDigit && hasSpecial) return null;
                          return 'Include upper, lower, number & special character.';
                        },
                      ),
                      const SizedBox(height: 12),
                      if (error != null) ...[const SizedBox(height: 8), Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error))],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: isLoading ? null : _submitEmailAuth,
                        child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(isLoading ? 'Please wait...' : (_isRegister ? 'Create Account' : 'Sign In'))),
                      ),
                      const SizedBox(height: 8),
                      TextButton(onPressed: isLoading ? null : () => setState(() => _isRegister = !_isRegister), child: Text(_isRegister ? 'Have an account? Sign in' : 'Need an account? Create one')),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _BrandAuthButton(label: 'Continue with Google', onPressed: isLoading ? null : _signInGoogle, brand: AuthBrand.google),
                      const SizedBox(height: 12),
                      _BrandAuthButton(label: 'Continue with Microsoft', onPressed: isLoading ? null : _signInMicrosoft, brand: AuthBrand.microsoft),
                      const SizedBox(height: 12),
                      if (!_isRegister)
                        TextButton(
                          onPressed: () async {
                            if (_emailController.text.isEmpty) return;
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              await FirebaseAuthService.sendPasswordResetEmail(email: _emailController.text.trim());
                              messenger.showSnackBar(const SnackBar(content: Text('Password reset email sent')));
                            } catch (e) {
                              messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
                            }
                          },
                          child: const Text('Forgot password?'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AuthBrand { google, microsoft }

class _BrandAuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AuthBrand brand;
  const _BrandAuthButton({required this.label, required this.onPressed, required this.brand});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (brand) {
      case AuthBrand.google:
        return _GoogleButton(label: label, onPressed: onPressed, dark: isDark);
      case AuthBrand.microsoft:
        return _MicrosoftButton(label: label, onPressed: onPressed, dark: isDark);
    }
  }
}

class _GoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  const _GoogleButton({required this.label, required this.onPressed, required this.dark});

  @override
  Widget build(BuildContext context) {
    final bg = Colors.white;
    final border = dark ? Colors.white : const Color(0xFFE0E0E0);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/brands/google_logo.svg', width: 22, height: 22),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600, letterSpacing: .2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MicrosoftButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool dark;
  const _MicrosoftButton({required this.label, required this.onPressed, required this.dark});

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF2C2C2C) : Colors.white;
    final border = dark ? Colors.white : const Color(0xFFE0E0E0);
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: bg,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset('assets/brands/microsoft_logo.svg', width: 20, height: 20),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: dark ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, letterSpacing: .2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter logo widgets removed in favor of official SVG assets for accurate branding.
