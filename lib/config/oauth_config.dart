/// Configuration for OAuth scopes based on development stage
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
