# Firebase Setup Guid1. **Add Android App to Firebase Project:*1. **Add iOS App to Firebase Project:**
   - In Firebase Console, click "Add app" > iOS icon
   - Register app with Bundle ID: `com.hadenhiles.influinbox` (check `ios/Runner.xcodeproj/project.pbxproj`)
   - Download `GoogleService-Info.plist`
   - Drag file into `ios/Runner/` in Xcode, ensuring "Copy items if needed" is checked- In Firebase Console, click "Add app" > Android icon
   - Register app with package name: `com.hadenhiles.influinbox` (check `android/app/build.gradle.kts`)
   - Download `google-services.json`
   - Place file in `android/app/` directory InfluInbox

## Overview
This guide provides step-by-step instructions for setting up Firebase in your Flutter project for Android, iOS, and Web platforms.

## Prerequisites
1. Flutter SDK installed
2. Firebase CLI installed: `npm install -g firebase-tools`
3. FlutterFire CLI installed: `dart pub global activate flutterfire_cli`
4. A Google account for Firebase Console access

## Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: `influinbox` (or your preferred name)
4. Configure Google Analytics (optional)
5. Click "Create project"

## Step 2: Platform-Specific Configuration

### Android Configuration
1. **Add Android App to Firebase Project:**
   - In Firebase Console, click "Add app" > Android icon
   - Register app with package name: `com.hadenhiles.influinbox` (check `android/app/src/main/AndroidManifest.xml`)
   - Download `google-services.json`
   - Place file in `android/app/` directory

2. **Update Android Gradle Files:**
   ```gradle
   // android/build.gradle (Project-level)
   buildscript {
     dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
     }
   }
   
   // android/app/build.gradle (App-level)
   apply plugin: 'com.google.gms.google-services'
   
   dependencies {
     implementation platform('com.google.firebase:firebase-bom:32.7.0')
   }
   ```

3. **Enable Multidex (if needed):**
   ```gradle
   // android/app/build.gradle
   android {
     defaultConfig {
       multiDexEnabled true
     }
   }
   
   dependencies {
     implementation 'androidx.multidex:multidex:2.0.1'
   }
   ```

### iOS Configuration
1. **Add iOS App to Firebase Project:**
   - In Firebase Console, click "Add app" > iOS icon
   - Register app with Bundle ID: `com.hadenhiles.influinbox` (check `ios/Runner/Info.plist`)
   - Download `GoogleService-Info.plist`
   - Drag file into `ios/Runner/` in Xcode, ensuring "Copy items if needed" is checked

2. **Update iOS Dependencies:**
   ```ruby
   # ios/Podfile
   platform :ios, '12.0'
   
   target 'Runner' do
     use_frameworks!
     use_modular_headers!
     
     flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
   end
   ```

3. **Run Pod Install:**
   ```bash
   cd ios && pod install --repo-update
   ```

### Web Configuration
1. **Add Web App to Firebase Project:**
   - In Firebase Console, click "Add app" > Web icon
   - Register app with nickname: `influinbox-web`
   - Copy the Firebase config object

2. **Update Web Configuration:**
   ```html
   <!-- web/index.html - Add before </body> tag -->
   <script type="module">
     import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js';
     import { getAnalytics } from 'https://www.gstatic.com/firebasejs/10.7.1/firebase-analytics.js';
     
     const firebaseConfig = {
       // Your config from Firebase Console
     };
     
     const app = initializeApp(firebaseConfig);
     const analytics = getAnalytics(app);
   </script>
   ```

## Step 3: Generate Firebase Options
Run the FlutterFire CLI to automatically generate the `firebase_options.dart` file:

```bash
flutterfire configure --project=your-project-id
```

This will:
- Automatically detect your platforms
- Generate the `lib/firebase_options.dart` file
- Configure all necessary settings

## Step 4: Update main.dart
The main.dart file has already been updated with Firebase initialization:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const ProviderScope(child: InfluInboxApp()));
}
```

## Step 5: Firebase Services Setup
The following Firebase services are available:

- **Authentication:** `firebase_auth`
- **Firestore Database:** `cloud_firestore`
- **Cloud Storage:** `firebase_storage`
- **Cloud Functions:** `cloud_functions`
- **Cloud Messaging:** `firebase_messaging`
- **App Check:** `firebase_app_check`

## Step 6: Enable Firebase Services
In Firebase Console, enable the services you need:

1. **Authentication:** Go to Authentication > Sign-in method
2. **Firestore:** Go to Firestore Database > Create database
3. **Storage:** Go to Storage > Get started
4. **Functions:** Go to Functions (requires Blaze plan)
5. **Messaging:** Go to Cloud Messaging
6. **App Check:** Go to App Check

## Platform-Specific Notes

### Android
- Minimum SDK version: 21 (Android 5.0)
- Ensure `google-services.json` is in `android/app/`
- Add Google Services plugin to app-level `build.gradle`

### iOS
- Minimum iOS version: 12.0
- Ensure `GoogleService-Info.plist` is added to Xcode project
- Run `pod install` after adding Firebase dependencies

### Web
- Add Firebase SDK scripts to `web/index.html`
- Configure hosting for Firebase Hosting (optional)
- Enable CORS for Cloud Functions if needed

## Security Rules Examples

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### Storage Security Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Troubleshooting

### Common Issues
1. **Build errors:** Ensure all configuration files are in correct locations
2. **Pod install issues:** Update CocoaPods and run `pod repo update`
3. **Web CORS errors:** Configure Firebase Hosting or update Cloud Functions CORS
4. **Android build errors:** Check Google Services plugin is applied correctly

### Verification Commands
```bash
# Check Firebase CLI
firebase --version

# Check FlutterFire CLI
flutterfire --version

# Verify Firebase project
firebase projects:list

# Test Flutter build
flutter build apk --debug
flutter build ios --debug
flutter build web --debug
```

## Next Steps
1. Implement authentication in your app
2. Set up Firestore data models
3. Configure push notifications
4. Set up Cloud Functions (if needed)
5. Implement security rules
6. Test on all target platforms
