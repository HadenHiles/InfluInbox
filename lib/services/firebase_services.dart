import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile', 'https://www.googleapis.com/auth/gmail.readonly', 'https://www.googleapis.com/auth/gmail.send']);

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

  /// Sign in with Google (Gmail)
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      // Sign in to Firebase with the Google credential
      return await _auth.signInWithCredential(credential);
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

      // Sign in with popup (web) or redirect (mobile)
      return await _auth.signInWithProvider(microsoftProvider);
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
