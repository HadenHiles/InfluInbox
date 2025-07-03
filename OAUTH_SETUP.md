# OAuth2 Setup Guide for Gmail and Outlook with Firebase Authentication

This guide provides detailed steps to register OAuth2 applications for Google (Gmail) and Microsoft (Outlook) for use with Firebase Authentication in your Flutter app.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Google OAuth2 Setup for Gma### Troubleshooting

### Common Issues

1. **"redirect_uri_mismatch"**: Ensure redirect URIs match exactly in OAuth config
2. **"invalid_client"**: Check client ID and secret are correct
3. **"insufficient_scope"**: Verify required scopes are added and consented
4. **iOS build errors**: Ensure URL schemes are correctly configured
5. **"Android package name and fingerprint already in use"**: 
   - Check if the package name is registered in another Google Cloud project
   - Use a different package name (e.g., add `.dev` suffix for development)
   - Or find and delete the existing registration if it's not neededgle-oauth2-setup-for-gmail)
- [Microsoft OAuth2 Setup for Outlook](#microsoft-oauth2-setup-for-outlook)
- [Firebase Authentication Configuration](#firebase-authentication-configuration)
- [Flutter App Configuration](#flutter-app-configuration)
- [Security Best Practices](#security-best-practices)
- [Testing the Implementation](#testing-the-implementation)

## Prerequisites

Before starting, ensure you have:
- A Firebase project created and configured
- Google account for Google Cloud Console access
- Microsoft account for Azure Portal access
- Flutter development environment set up

## Google OAuth2 Setup for Gmail

### Step 1: Create or Select Google Cloud Project

1. Navigate to the [Google Cloud Console](https://console.cloud.google.com/)
2. Click the project dropdown at the top of the page
3. Either select an existing project or click **"New Project"**
4. If creating new:
   - Enter project name: `InfluInbox-OAuth` (or your preferred name)
   - Select your organization (if applicable)
   - Click **"Create"**
5. Wait for the project to be created and ensure it's selected

### Step 2: Enable Required APIs

1. In the Google Cloud Console sidebar, go to **"APIs & Services"** > **"Library"**
2. Search for and enable the following APIs:
   - **Gmail API**: Click on it and press **"Enable"**
   - **Google+ API**: Search, click, and **"Enable"** (for profile information)
   - **People API**: Search, click, and **"Enable"** (for contact information)

### Step 3: Configure OAuth Consent Screen

1. Go to **"APIs & Services"** > **"OAuth consent screen"**
2. Select user type:
   - Choose **"External"** (unless you have Google Workspace)
   - Click **"Create"**

3. **OAuth consent screen** tab - Fill in required information:
   - **App name**: `InfluInbox`
   - **User support email**: Your email address
   - **App logo**: Upload your app logo (optional but recommended)
   - **App domain** (if you have a website):
     - Application home page: `https://yourdomain.com`
     - Application privacy policy link: `https://yourdomain.com/privacy`
     - Application terms of service link: `https://yourdomain.com/terms`
   - **Developer contact information**: Your email address

4. Click **"Save and Continue"**

5. **Scopes** tab - **IMPORTANT FOR DEVELOPMENT**:
   - **For Development**: Start with basic scopes that don't require verification:
     - `https://www.googleapis.com/auth/userinfo.email`
     - `https://www.googleapis.com/auth/userinfo.profile`
     - `openid`, `email`, `profile`
   - **For Production**: Add Gmail scopes after app verification:
     - `https://www.googleapis.com/auth/gmail.readonly`
     - `https://www.googleapis.com/auth/gmail.send`
     - `https://www.googleapis.com/auth/gmail.compose`
   - Click **"Update"**
   - Click **"Save and Continue"**

6. **Test users** tab:
   - Add your email and any other test user emails
   - In testing mode, only these users can access your app
   - Click **"Save and Continue"**

7. **Keep your app in "Testing" status** until ready for production verification

> **Note**: In testing mode, you can use your app with up to 100 test users without Google verification. This allows you to develop and test your Gmail integration before submitting for review.

### Step 4: Create OAuth2 Credentials

1. Go to **"APIs & Services"** > **"Credentials"**
2. Click **"Create Credentials"** > **"OAuth client ID"**
3. Configure the OAuth client:
   - **Application type**: Select **"Web application"**
   - **Name**: `InfluInbox Web Client`
   
4. **Authorized redirect URIs** - Add these URIs:
   - For Firebase: `https://your-project-id.firebaseapp.com/__/auth/handler`
   - For local development: `http://localhost:3000/__/auth/handler`
   - Replace `your-project-id` with your actual Firebase project ID

5. Click **"Create"**

6. **Important**: Copy and securely store:
   - **Client ID** (ends with `.apps.googleusercontent.com`)
   - **Client Secret**

### Step 5: Configure for Mobile Apps

1. Create additional OAuth clients for mobile:
   - Click **"Create Credentials"** > **"OAuth client ID"**
   - **Application type**: **"Android"** 
   - **Name**: `InfluInbox Android`
   - **Package name**: Your Android package name (e.g., `com.hadenhiles.influinbox`)
   - **SHA-1 certificate fingerprint**: Get this by running:
     ```bash
     cd android && ./gradlew signingReport
     ```

2. For iOS:
   - **Application type**: **"iOS"**
   - **Name**: `InfluInbox iOS`
   - **Bundle ID**: Your iOS bundle identifier

## Microsoft OAuth2 Setup for Outlook

### Step 1: Register Application in Azure Portal

1. Navigate to [Azure Portal](https://portal.azure.com/)
2. Sign in with your Microsoft account
3. Search for **"Microsoft Entra ID"** in the top search bar (formerly Azure Active Directory)
   - Alternative: Go to **"All services"** > **"Identity"** > **"Microsoft Entra ID"**
   - Or use direct URL: `https://portal.azure.com/#view/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/~/Overview`
4. In the left sidebar, click **"App registrations"**
5. Click **"New registration"**

### Step 2: Configure Application Registration

1. Fill in the application details:
   - **Name**: `InfluInbox`
   - **Supported account types**: Select **"Accounts in any organizational directory (Any Azure AD directory - Multitenant) and personal Microsoft accounts (e.g. Skype, Xbox)"**
   - **Redirect URI**: 
     - Platform: **"Web"**
     - URI: `https://your-project-id.firebaseapp.com/__/auth/handler`
   
2. Click **"Register"**

3. **Save these important values** from the Overview page:
   - **Application (client) ID**
   - **Directory (tenant) ID**

### Step 3: Configure API Permissions

1. In your registered app, go to **"API permissions"** in the left sidebar
2. Click **"Add a permission"**
3. Select **"Microsoft Graph"**
4. Choose **"Delegated permissions"**
5. Add these permissions:
   - **Mail permissions**:
     - `Mail.Read`
     - `Mail.ReadWrite`
     - `Mail.Send`
   - **User permissions**:
     - `User.Read`
   - **OpenID permissions**:
     - `openid`
     - `email`
     - `profile`

6. Click **"Add permissions"**
7. Click **"Grant admin consent for [your organization]"** (if you're an admin)
   - If you're not an admin, contact your administrator to grant consent

### Step 4: Create Client Secret

1. Go to **"Certificates & secrets"** in the left sidebar
2. Click **"New client secret"**
3. Configure the secret:
   - **Description**: `InfluInbox Client Secret`
   - **Expires**: Choose **24 months** (recommended)
4. Click **"Add"**
5. **Important**: Immediately copy the **Value** field - you won't be able to see it again!

### Step 5: Add Additional Redirect URIs (Optional)

1. Go to **"Authentication"** in the left sidebar
2. Under **"Redirect URIs"**, click **"Add URI"**
3. Add additional URIs as needed:
   - `http://localhost:3000/__/auth/handler` (for local development)
   - Any other domains you'll use

## Firebase Authentication Configuration

### Step 1: Enable Authentication Providers

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **"Authentication"** > **"Sign-in method"**

### Step 2: Configure Google Provider

1. Click on **"Google"** in the providers list
2. Click the **"Enable"** toggle
3. Enter your OAuth credentials:
   - **Web SDK configuration**:
     - **Web client ID**: Your Google Client ID
     - **Web client secret**: Your Google Client Secret
4. Click **"Save"**

### Step 3: Configure Microsoft Provider

1. Click on **"Microsoft"** in the providers list
2. Click the **"Enable"** toggle
3. Enter your OAuth credentials:
   - **Application (client) ID**: Your Microsoft Application ID
   - **Application (client) secret**: Your Microsoft Client Secret
4. Click **"Save"**

### Step 4: Update Authorized Domains

1. Still in the **"Sign-in method"** tab
2. Scroll down to **"Authorized domains"**
3. Ensure these domains are listed:
   - `localhost` (for development)
   - Your production domain
   - `your-project-id.firebaseapp.com`

## Flutter App Configuration

### Step 1: Dependencies

Ensure your `pubspec.yaml` includes:

```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  google_sign_in: ^6.2.1
  extension_google_sign_in_as_googleapis_auth: ^2.0.12
```

### Step 2: Android Configuration

1. **Add SHA-1 fingerprints to Firebase**:
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy the SHA-1 and add it to Firebase Console > Project Settings > Your apps > Android app

2. **Download updated `google-services.json`** and replace the existing file in `android/app/`

### Step 3: iOS Configuration

1. **Update `ios/Runner/Info.plist`**:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>REVERSED_CLIENT_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```
   Replace `YOUR_REVERSED_CLIENT_ID` with the value from your `GoogleService-Info.plist`

2. **Download updated `GoogleService-Info.plist`** and replace the existing file in `ios/Runner/`

## Security Best Practices

### 1. Environment Variables

Create a `.env` file (copy from `.env.example`):

```bash
# Copy the example file
cp .env.example .env

# Edit with your actual values
# DO NOT commit this file to version control
```

### 2. Secure Storage

- Never commit OAuth secrets to version control
- Use Firebase environment configuration for production
- Implement proper token refresh mechanisms
- Use HTTPS only for redirect URIs

### 3. Scope Management

- Request only the minimum required scopes
- Use incremental authorization when possible
- Regularly audit and remove unused permissions

### 4. Production Considerations

- Switch to production App Check providers:
  - Android: Play Integrity API
  - iOS: App Attest
  - Web: reCAPTCHA v3
- Implement proper error handling and user feedback
- Set up monitoring and logging

## Testing the Implementation

### Step 1: Run the Example

1. Use the OAuth example page (`lib/examples/oauth_example.dart`)
2. Test both Google and Microsoft sign-in flows
3. Verify access tokens are obtained

### Step 2: Test API Access

Once authenticated, test API calls:

```dart
// Example Gmail API call
final response = await http.get(
  Uri.parse('https://gmail.googleapis.com/gmail/v1/users/me/profile'),
  headers: {'Authorization': 'Bearer $googleAccessToken'},
);

// Example Microsoft Graph API call
final response = await http.get(
  Uri.parse('https://graph.microsoft.com/v1.0/me/messages'),
  headers: {'Authorization': 'Bearer $microsoftAccessToken'},
);
```

### Step 3: Error Testing

- Test with invalid credentials
- Test network failure scenarios
- Test token expiration handling

## Troubleshooting

### Common Issues

1. **"redirect_uri_mismatch"**: Ensure redirect URIs match exactly in OAuth config
2. **"invalid_client"**: Check client ID and secret are correct
3. **"insufficient_scope"**: Verify required scopes are added and consented
4. **iOS build errors**: Ensure URL schemes are correctly configured

### Debug Steps

1. Check Firebase Authentication logs
2. Verify OAuth consent screen is approved
3. Ensure test users are added for development
4. Check network connectivity and firewall settings

## Additional Resources

- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Microsoft Identity Platform Documentation](https://docs.microsoft.com/en-us/azure/active-directory/develop/)
- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Flutter Google Sign-In Plugin](https://pub.dev/packages/google_sign_in)

## Support

If you encounter issues:

1. Check the Firebase Console for authentication errors
2. Review Google Cloud Console API quotas and usage
3. Verify Azure AD application configuration
4. Test with a fresh browser session or incognito mode
