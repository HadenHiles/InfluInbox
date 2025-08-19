import '../services/oauth_runtime_config.dart';

/// Configuration for OAuth scopes and dynamic client IDs
class OAuthConfig {
  static const bool isDevelopment = true; // Set to false for production

  /// Google OAuth scopes for development (no verification required)
  static const List<String> developmentGoogleScopes = ['email', 'profile', 'openid', 'https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/userinfo.profile'];

  /// Google OAuth scopes for production (require verification)
  static const List<String> productionGoogleScopes = [
    'email',
    'profile',
    'openid',
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send',
    'https://www.googleapis.com/auth/gmail.compose',
    'https://www.googleapis.com/auth/gmail.modify',
  ];

  /// Microsoft OAuth scopes
  static const List<String> microsoftScopes = ['https://graph.microsoft.com/Mail.Read', 'https://graph.microsoft.com/Mail.Send', 'https://graph.microsoft.com/Mail.ReadWrite', 'https://graph.microsoft.com/User.Read'];

  // Google client ID resolution order: dart-define > runtime callable > fallback
  static String get googleClientId {
    const define = String.fromEnvironment('GOOGLE_CLIENT_ID');
    if (define.isNotEmpty) return define;
    final runtime = OAuthRuntimeConfigService.googleClientId;
    if (runtime != null && runtime.isNotEmpty) return runtime;
    return '184330992881-ecqb8c4t8g9co4sjgq3qq5d66q94dmqb.apps.googleusercontent.com'; // fallback dev id
  }

  // Microsoft client ID resolution order: dart-define > runtime callable > fallback
  static String get microsoftClientId {
    const define = String.fromEnvironment('MICROSOFT_CLIENT_ID');
    if (define.isNotEmpty) return define;
    final runtime = OAuthRuntimeConfigService.microsoftClientId;
    if (runtime != null && runtime.isNotEmpty) return runtime;
    return '9c8de9f3-70cf-4810-a695-3ef750bbef69';
  }

  // Registered redirect URI in Azure AD (for mobile: custom scheme; for web: https://<your-domain>/auth/microsoft)
  // Example custom scheme to register in AndroidManifest and iOS Info.plist
  static const String microsoftRedirectUri = 'influinbox://auth/microsoft';

  /// Get appropriate Google scopes based on development stage
  static List<String> get googleScopes {
    return isDevelopment ? developmentGoogleScopes : productionGoogleScopes;
  }

  /// Check if Gmail features are available
  static bool get hasGmailFeatures {
    return !isDevelopment || const bool.fromEnvironment('ENABLE_GMAIL_DEV', defaultValue: false);
  }

  /// Get user-friendly message about Gmail limitations
  static String get gmailLimitationMessage {
    if (isDevelopment) {
      return 'Gmail features are limited in development. Full access requires Google verification.';
    }
    return '';
  }
}
