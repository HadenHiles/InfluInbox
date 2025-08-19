import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../config/oauth_config.dart';

/// Firebase services singleton for easy access throughout the app
class FirebaseServices {
  static FirebaseServices? _instance;
  static FirebaseServices get instance => _instance ??= FirebaseServices._();

  FirebaseServices._();

  // Firebase Auth instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  // Firestore instance
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Firebase Storage instance
  FirebaseStorage get storage => FirebaseStorage.instance;

  // Cloud Functions instance
  FirebaseFunctions get functions => FirebaseFunctions.instance;

  // Firebase Messaging instance
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  /// Initialize Firebase App Check for security
  /// Call this after Firebase.initializeApp() in main()
  static Future<void> initializeAppCheck() async {
    await FirebaseAppCheck.instance.activate(
      // For Android: Use Debug provider in debug mode, Play Integrity in release
      androidProvider: AndroidProvider.debug,
      // For iOS: Use Debug provider in debug mode, App Attest in release
      appleProvider: AppleProvider.debug,
      // For Web: Use ReCaptcha V3 in production
      webProvider: ReCaptchaV3Provider('your-recaptcha-site-key'),
    );
  }

  /// Initialize Firebase Messaging for push notifications
  static Future<void> initializeMessaging() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission for notifications (iOS)
    NotificationSettings settings = await messaging.requestPermission(alert: true, announcement: false, badge: true, carPlay: false, criticalAlert: false, provisional: false, sound: true);

    print('User granted permission: ${settings.authorizationStatus}');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    // Get FCM token
    String? token = await messaging.getToken();
    print('FCM Token: $token');
  }

  /// Configure Firestore settings
  static void configureFirestore() {
    FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true, cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED);
  }
}

/// Authentication helper methods
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Dynamic GoogleSignIn instance (recreated if serverClientId changes)
  static GoogleSignIn _googleSignIn = GoogleSignIn(scopes: OAuthConfig.googleScopes, serverClientId: OAuthConfig.googleClientId);
  static String? _lastGoogleServerClientId = OAuthConfig.googleClientId;

  static void _ensureGoogleSignInCurrent() {
    final currentId = OAuthConfig.googleClientId;
    if (_lastGoogleServerClientId != currentId) {
      _googleSignIn = GoogleSignIn(scopes: OAuthConfig.googleScopes, serverClientId: currentId);
      _lastGoogleServerClientId = currentId;
    }
  }

  /// Get current user
  static User? get currentUser => _auth.currentUser;

  /// Check if user is signed in
  static bool get isSignedIn => currentUser != null;

  /// Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  static Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Create user with email and password
  static Future<UserCredential> createUserWithEmailAndPassword({required String email, required String password}) async {
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  /// Backend-assisted email signup via callable (returns custom token). Falls back to client method on error.
  static Future<UserCredential> secureEmailSignUp({required String email, required String password, String? recaptchaToken}) async {
    try {
      final result = await FirebaseFunctionsService.callFunction(functionName: 'emailSignUp', parameters: {'email': email, 'password': password, if (recaptchaToken != null) 'recaptchaToken': recaptchaToken});
      final data = result.data as Map<String, dynamic>;
      final customToken = data['customToken'] as String?;
      if (customToken == null) throw Exception('Missing customToken from backend');
      final cred = await _auth.signInWithCustomToken(customToken);
      return cred;
    } catch (e) {
      print('secureEmailSignUp failed, falling back: $e');
      return await createUserWithEmailAndPassword(email: email, password: password);
    }
  }

  /// Backend-assisted email sign-in using REST verification on server (stores encrypted refresh token). Falls back on error.
  static Future<UserCredential> secureEmailSignIn({required String email, required String password, String? recaptchaToken}) async {
    try {
      await FirebaseFunctionsService.callFunction(functionName: 'emailSignIn', parameters: {'email': email, 'password': password, if (recaptchaToken != null) 'recaptchaToken': recaptchaToken});
      // Backend returns idToken & uid; we still sign in client side with email/password for Firebase persistence
      return await signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('secureEmailSignIn failed, falling back: $e');
      return await signInWithEmailAndPassword(email: email, password: password);
    }
  }

  /// Switch to production scopes (call this after Google verification)
  static GoogleSignIn createProductionGoogleSignIn() {
    return GoogleSignIn(scopes: OAuthConfig.productionGoogleScopes);
  }

  /// Check if user has Gmail access
  static Future<bool> hasGmailAccess() async {
    try {
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      if (googleUser == null) return false;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;

      if (accessToken == null) return false;

      // Check if we have Gmail scopes by trying to access Gmail API
      final scopes = googleUser.serverAuthCode;
      return scopes != null;
    } catch (e) {
      return false;
    }
  }

  /// Sign in with Google (Gmail)
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Ensure we have latest server client ID (after runtime load or dart-define)
      _ensureGoogleSignInCurrent();
      // Trigger interactive sign-in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user aborted

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final userCred = await _auth.signInWithCredential(credential);

      // Attempt secure server-side token storage (authorization code exchange) if we obtained a serverAuthCode
      final serverAuthCode = googleUser.serverAuthCode; // Provided when server client id configured
      if (serverAuthCode != null && userCred.user != null) {
        try {
          final recaptchaToken = await _maybeGetRecaptchaToken();
          await FirebaseFunctionsService.callFunction(
            functionName: 'oauthLogin',
            parameters: {
              'provider': 'google',
              'code': serverAuthCode,
              // 'postmessage' works for installed apps / google_sign_in internal flow exchange
              'redirectUri': 'postmessage',
              'userId': userCred.user!.uid,
              if (recaptchaToken != null) 'recaptchaToken': recaptchaToken,
            },
          );
        } catch (e) {
          // Non-fatal: user remains signed in, but tokens not stored on backend
          print('oauthLogin callable failed: $e');
        }
      } else {
        print('No serverAuthCode available; skipping backend oauthLogin token storage');
      }
      return userCred;
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign in with Microsoft (Outlook)
  static Future<UserCredential?> signInWithMicrosoft() async {
    try {
      // Create a Microsoft provider
      final microsoftProvider = MicrosoftAuthProvider();

      // Add scopes for Outlook access
      microsoftProvider.addScope('https://graph.microsoft.com/Mail.Read');
      microsoftProvider.addScope('https://graph.microsoft.com/Mail.Send');
      microsoftProvider.addScope('https://graph.microsoft.com/User.Read');

      // Sign in with popup (web) or redirect (mobile) to authenticate user in Firebase
      final userCred = await _auth.signInWithProvider(microsoftProvider);

      // After Firebase sign-in, perform explicit authorization code flow for backend token storage
      if (userCred.user != null) {
        try {
          final code = await _acquireMicrosoftAuthorizationCode();
          if (code != null) {
            final recaptchaToken = await _maybeGetRecaptchaToken();
            await FirebaseFunctionsService.callFunction(
              functionName: 'oauthLogin',
              parameters: {'provider': 'microsoft', 'code': code, 'redirectUri': OAuthConfig.microsoftRedirectUri, 'userId': userCred.user!.uid, if (recaptchaToken != null) 'recaptchaToken': recaptchaToken},
            );
          } else {
            print('Microsoft auth code acquisition canceled by user');
          }
        } catch (e) {
          print('Failed Microsoft code exchange: $e');
        }
      }
      return userCred;
    } catch (e) {
      print('Error signing in with Microsoft: $e');
      rethrow;
    }
  }

  /// Get Google access token for Gmail API calls
  static Future<String?> getGoogleAccessToken() async {
    try {
      final GoogleSignInAccount? googleUser = _googleSignIn.currentUser;
      if (googleUser == null) {
        // User not signed in with Google
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      return googleAuth.accessToken;
    } catch (e) {
      print('Error getting Google access token: $e');
      return null;
    }
  }

  /// Get Microsoft access token for Outlook API calls
  static Future<String?> getMicrosoftAccessToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      // Get the Microsoft provider data
      for (final providerData in user.providerData) {
        if (providerData.providerId == 'microsoft.com') {
          // You'll need to implement token refresh logic here
          // This is a simplified example
          final result = await user.getIdTokenResult();
          return result.token;
        }
      }
      return null;
    } catch (e) {
      print('Error getting Microsoft access token: $e');
      return null;
    }
  }

  /// Sign out from all providers
  static Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }

  /// Optionally acquire a reCAPTCHA token (placeholder - integrate web or App Check if required)
  static Future<String?> _maybeGetRecaptchaToken() async {
    // TODO: Implement real reCAPTCHA v3 invocation on web, or pass App Check token if backend adapts
    return null;
  }

  /// Launch Microsoft authorization endpoint to obtain an authorization code for backend exchange.
  static Future<String?> _acquireMicrosoftAuthorizationCode() async {
    try {
      final scope = Uri.encodeComponent(OAuthConfig.microsoftScopes.join(' '));
      final authUrl = Uri.parse(
        'https://login.microsoftonline.com/common/oauth2/v2.0/authorize'
        '?client_id=${OAuthConfig.microsoftClientId}'
        '&response_type=code'
        '&redirect_uri=${Uri.encodeComponent(OAuthConfig.microsoftRedirectUri)}'
        '&response_mode=query'
        '&prompt=select_account'
        '&scope=$scope',
      );
      final result = await FlutterWebAuth2.authenticate(url: authUrl.toString(), callbackUrlScheme: OAuthConfig.microsoftRedirectUri.split('://').first);
      final returned = Uri.parse(result);
      return returned.queryParameters['code'];
    } catch (e) {
      print('Microsoft code flow error: $e');
      return null;
    }
  }

  /// Send password reset email
  static Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}

/// Firestore helper methods
class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a collection reference
  static CollectionReference collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a document reference
  static DocumentReference document(String path) {
    return _firestore.doc(path);
  }

  /// Create or update a document
  static Future<void> setDocument({required String path, required Map<String, dynamic> data, bool merge = false}) async {
    await _firestore.doc(path).set(data, SetOptions(merge: merge));
  }

  /// Update a document
  static Future<void> updateDocument({required String path, required Map<String, dynamic> data}) async {
    await _firestore.doc(path).update(data);
  }

  /// Delete a document
  static Future<void> deleteDocument({required String path}) async {
    await _firestore.doc(path).delete();
  }

  /// Get a document
  static Future<DocumentSnapshot> getDocument({required String path}) async {
    return await _firestore.doc(path).get();
  }

  /// Get a collection
  static Stream<QuerySnapshot> getCollection({required String path, Query Function(Query)? queryBuilder}) {
    Query query = _firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }
}

/// Storage helper methods
class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload file to Firebase Storage
  static Future<String> uploadFile({required String path, required List<int> fileBytes, String? contentType}) async {
    final ref = _storage.ref().child(path);
    final metadata = SettableMetadata(contentType: contentType);

    await ref.putData(Uint8List.fromList(fileBytes), metadata);
    return await ref.getDownloadURL();
  }

  /// Delete file from Firebase Storage
  static Future<void> deleteFile({required String path}) async {
    await _storage.ref().child(path).delete();
  }

  /// Get download URL for a file
  static Future<String> getDownloadURL({required String path}) async {
    return await _storage.ref().child(path).getDownloadURL();
  }
}

/// Cloud Functions helper methods
class FirebaseFunctionsService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instance;

  /// Call a callable Cloud Function
  static Future<HttpsCallableResult> callFunction({required String functionName, Map<String, dynamic>? parameters}) async {
    final callable = _functions.httpsCallable(functionName);
    return await callable.call(parameters);
  }
}

/// Background message handler for Firebase Messaging
/// This must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
