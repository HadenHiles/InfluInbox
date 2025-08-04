import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utility functions for string manipulation and validation
class StringUtils {
  /// Check if string is null or empty
  static bool isEmpty(String? str) {
    return str == null || str.trim().isEmpty;
  }

  /// Check if string is not null and not empty
  static bool isNotEmpty(String? str) {
    return !isEmpty(str);
  }

  /// Capitalize first letter of each word
  static String capitalize(String str) {
    if (isEmpty(str)) return str;

    return str
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  /// Convert string to title case
  static String toTitleCase(String str) {
    return capitalize(str);
  }

  /// Truncate string to specified length
  static String truncate(String str, int length, {String suffix = '...'}) {
    if (str.length <= length) return str;
    return str.substring(0, length - suffix.length) + suffix;
  }

  /// Remove HTML tags from string
  static String stripHtml(String htmlString) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '');
  }

  /// Extract plain text from HTML
  static String htmlToPlainText(String htmlString) {
    String plainText = stripHtml(htmlString);

    // Replace common HTML entities
    plainText = plainText.replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>').replaceAll('&quot;', '"').replaceAll('&#39;', "'");

    // Remove extra whitespace
    plainText = plainText.replaceAll(RegExp(r'\s+'), ' ').trim();

    return plainText;
  }

  /// Validate email address
  static bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Extract domain from email address
  static String? getEmailDomain(String email) {
    if (!isValidEmail(email)) return null;
    return email.split('@').last;
  }

  /// Get initials from name
  static String getInitials(String name, {int maxInitials = 2}) {
    if (isEmpty(name)) return '';

    final words = name.trim().split(RegExp(r'\s+'));
    final initials = words.take(maxInitials).map((word) => word.isNotEmpty ? word[0].toUpperCase() : '').where((initial) => initial.isNotEmpty).join();

    return initials;
  }

  /// Generate a hash from string
  static String generateHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a short hash (first 8 characters)
  static String generateShortHash(String input) {
    return generateHash(input).substring(0, 8);
  }

  /// Sanitize filename by removing invalid characters
  static String sanitizeFilename(String filename) {
    // Remove or replace invalid characters for filenames
    return filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_').replaceAll(RegExp(r'\s+'), '_').toLowerCase();
  }

  /// Convert bytes to human readable size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Generate random string
  static String generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;

    return List.generate(length, (index) {
      return chars[(random + index) % chars.length];
    }).join();
  }

  /// Check if string contains only alphabetic characters
  static bool isAlphabetic(String str) {
    return RegExp(r'^[a-zA-Z]+$').hasMatch(str);
  }

  /// Check if string contains only numeric characters
  static bool isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  /// Check if string is alphanumeric
  static bool isAlphanumeric(String str) {
    return RegExp(r'^[a-zA-Z0-9]+$').hasMatch(str);
  }

  /// Convert camelCase to snake_case
  static String camelToSnake(String camelCase) {
    return camelCase.replaceAllMapped(RegExp(r'[A-Z]'), (match) => '_${match[0]!.toLowerCase()}').replaceFirst(RegExp(r'^_'), '');
  }

  /// Convert snake_case to camelCase
  static String snakeToCamel(String snakeCase) {
    final words = snakeCase.split('_');
    if (words.isEmpty) return snakeCase;

    final camelCase = words.first + words.skip(1).map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1)).join();

    return camelCase;
  }
}
