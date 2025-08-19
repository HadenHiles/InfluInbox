import 'package:cloud_functions/cloud_functions.dart';

/// Runtime-loaded OAuth configuration fetched from secure backend callables.
class OAuthRuntimeConfigService {
  static String? _googleClientId;
  static String? _microsoftClientId;
  static bool _loaded = false;

  static String? get googleClientId => _googleClientId;
  static String? get microsoftClientId => _microsoftClientId;
  static bool get isLoaded => _loaded;

  /// Loads public OAuth client IDs from Cloud Function `getOAuthPublicConfig`.
  /// Safe to call multiple times; subsequent calls are no-ops once loaded unless forceReload == true.
  static Future<void> load({bool forceReload = false}) async {
    if (_loaded && !forceReload) return;
    final callable = FirebaseFunctions.instance.httpsCallable('getOAuthPublicConfig');
    final result = await callable.call();
    final data = Map<String, dynamic>.from(result.data as Map);
    _googleClientId = data['googleClientId'] as String?;
    _microsoftClientId = data['microsoftClientId'] as String?;
    _loaded = true;
  }
}
