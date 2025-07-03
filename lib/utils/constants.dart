/// Application constants
class AppConstants {
  // App Information
  static const String appName = 'InfluInbox';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Manage your emails efficiently';

  // API Configuration
  static const String gmailApiBaseUrl = 'https://gmail.googleapis.com/gmail/v1';
  static const String outlookApiBaseUrl = 'https://graph.microsoft.com/v1.0';

  // OAuth Scopes
  static const List<String> gmailScopes = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send',
    'https://www.googleapis.com/auth/gmail.compose',
    'https://www.googleapis.com/auth/gmail.modify',
  ];

  static const List<String> outlookScopes = ['https://graph.microsoft.com/Mail.Read', 'https://graph.microsoft.com/Mail.Send', 'https://graph.microsoft.com/Mail.ReadWrite', 'https://graph.microsoft.com/User.Read'];

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String cacheKey = 'email_cache';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // File Limits
  static const int maxAttachmentSize = 25 * 1024 * 1024; // 25MB
  static const List<String> allowedImageTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

  static const List<String> allowedDocumentTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'text/plain',
  ];

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String authError = 'Authentication failed. Please sign in again.';
  static const String permissionError = 'Permission denied. Please check your account permissions.';

  // Success Messages
  static const String emailSentSuccess = 'Email sent successfully!';
  static const String emailDeletedSuccess = 'Email deleted successfully!';
  static const String emailArchivedSuccess = 'Email archived successfully!';

  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineMode = false;
  static const bool enableDarkMode = true;

  // URLs
  static const String privacyPolicyUrl = 'https://influinbox.com/privacy';
  static const String termsOfServiceUrl = 'https://influinbox.com/terms';
  static const String supportUrl = 'https://influinbox.com/support';
  static const String githubUrl = 'https://github.com/hadenhiles/influinbox';

  // Regular Expressions
  static final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  static final RegExp phoneRegex = RegExp(r'^\+?1?-?\.?\s?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$');

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String displayTimeFormat = 'h:mm a';
}
