# InfluInbox Flutter App Roadmap

A step-by-step checklist to kickstart and organize the InfluInbox Flutter app, optimized for Copilot Agent mode and seamless Firebase integration.

---

## 🟢 Phase 1: Project & Environment Setup

- [x] **Create & Initialize Project Repo**

  - Create GitHub repo `InfluInbox` (manual or via command).
  - **Copilot:**  
    `Create a new Flutter 3.x project named influinbox with null safety and Riverpod for state management.`
  - **Copilot:**  
    `Initialize the repo with a standard .gitignore, README.md, and MIT license.`

- [x] **Set Up Firebase Project & Services**

  - Create Firebase project `InfluInbox` via [Firebase Console](https://console.firebase.google.com/)
  - Enable: Authentication, Firestore, Storage, Functions, Hosting, Cloud Messaging.
  - **Copilot (if unsure):**  
    `Give me step-by-step instructions to set up a Firebase project with Auth, Firestore, Storage, Functions, Hosting, and Cloud Messaging for a Flutter app.`
  - Download config files (`google-services.json`, `GoogleService-Info.plist`, web config).

- [x] **Configure Firebase in Flutter**

  - **Copilot:**  
    `Add firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_functions, firebase_messaging, firebase_app_check, and firebase_appauth to pubspec.yaml.`
  - **Copilot:**  
    `Generate setup code to initialize Firebase for Android, iOS, and web in Flutter. Show platform-specific notes for config files.`
  - Place downloaded config files in their respective platform folders.

- [x] **Enable Google & Microsoft OAuth2 Apps**

  - Register Google OAuth2 app (Gmail) and Microsoft OAuth2 app (Outlook).
  - Add redirect URIs (Firebase function URLs).
  - **Copilot (if unsure):**  
    `Give me detailed steps to register OAuth2 apps for Google (Gmail) and Microsoft (Outlook) for use with Firebase Authentication.`
  - Store client IDs/secrets securely for backend config.

- [x] **Project Structure & Boilerplate**
  - **Copilot:**  
    `Set up recommended project folders: /lib/features, /lib/services, /lib/models, /lib/providers, /lib/widgets, /lib/utils.`
  - **Copilot:**  
    `Add go_router for navigation and show basic router config.`
  - **Copilot:**  
    `Add basic Riverpod provider for Auth state.`

---

## 🟠 Phase 1.5: Branding & Theme System

- [x] **Create a Theme Screen / Design System Showcase**
  - **Copilot:**  
    `Create a /lib/features/theme/theme_screen.dart page that displays all major widgets, buttons, text styles, inputs, cards, and color swatches used in the app.`
  - **Copilot:**  
    `Set up theme extensions for colors, typography, and component shapes. Make them easily editable in one place.`
  - Use this screen to tweak and preview branding, app colors, text, buttons, and general UI identity before wider implementation.
  - Add a navigation route to access Theme Screen from the app menu or splash page.

---

## 🟡 Phase 2: Core Feature Development

- [ ] **Smart Email Sync (OAuth2 + Sync Jobs)**

  - **Copilot:**  
    `Set up Firebase Callable Function in Node.js to handle OAuth2 login with Gmail and Outlook, securely storing tokens in Firestore (encrypted).`
  - **Copilot:**  
    `Write scheduled Cloud Function to pull latest emails every 5 min and categorize them with simple keyword rules.`
  - **Copilot:**  
    `Write Flutter UI for connecting an account, triggering OAuth2, and showing inbox list with filters for Deals, Negotiation, Deliverables, Spam.`
  - **Copilot (if API setup fails):**  
    `Show me how to set up Gmail and Outlook API credentials, and required OAuth2 scopes for read/send access.`

- [ ] **AI Reply Assistant**

  - **Copilot:**  
    `Create Cloud Function that calls OpenAI/Gemini API, passing email thread and user’s saved tone/rate card from Firestore.`
  - **Copilot:**  
    `In Flutter, add onboarding step to set preferred reply tone and upload a sample email.`
  - **Copilot:**  
    `Build Compose Reply UI: show AI suggestion, allow edits, and send via backend function.`

- [ ] **Contract Summary (AI Parsing)**

  - **Copilot:**  
    `Add backend function to detect PDF/DOCX attachments, upload to Firebase Storage, extract text, and summarize with OpenAI/Gemini.`
  - **Copilot:**  
    `Show summary and highlight ‘red flag’ clauses in UI with expandable cards.`
  - **Copilot:**  
    `Store summary and contract metadata in Firestore.`

- [ ] **Campaign Tracker**

  - **Copilot:**  
    `Create Firestore model and Flutter UI to let user select thread → create campaign object with status enum (Negotiation, Accepted, Delivered, Paid).`
  - **Copilot:**  
    `Allow adding deliverables, deadlines, links (as subcollections).`
  - **Copilot:**  
    `Scheduled function checks deadlines and sends notifications.`

- [ ] **One-Click Reports**

  - **Copilot:**  
    `Integrate YouTube/Instagram OAuth2 flow for metrics. Store access tokens securely.`
  - **Copilot:**  
    `Pull latest metrics into Firestore.`
  - **Copilot:**  
    `Generate PDF reports or shareable Firebase Dynamic Links via Cloud Function.`
  - **Copilot:**  
    `Build report preview/download UI.`

- [ ] **Follow-Up & Nudges**
  - **Copilot:**  
    `Create scheduled Cloud Function to scan threads with no reply >48hr, use AI to draft follow-up, show prompt in app, and log actions to Firestore.`

---

## 🟣 Phase 3: Testing, Compliance, & Polish

- [ ] **Security & Compliance**

  - **Copilot:**  
    `Add Firebase rules to restrict access by user.`
  - **Copilot:**  
    `Add audit logging to Firestore for every read/write/send.`
  - **Copilot:**  
    `Expose callable endpoints for GDPR data export and delete.`

- [ ] **Unit & Integration Tests**

  - **Copilot:**  
    `Generate unit tests for each feature based on expected outcomes.`
  - **Copilot:**  
    `Write integration tests for OAuth2, email sync, contract summary, and campaign tracker flows.`

- [ ] **Prepare for Deployment**
  - **Copilot:**  
    `Set up Firebase Hosting for web build (PWA).`
  - **Copilot:**  
    `Add CI/CD config (GitHub Actions for build/test/deploy on push).`
  - **Copilot:**  
    `Write deployment checklist and basic user onboarding docs.`

---

## 📋 Quick Reference Copilot Prompts

- `Set up a new Flutter project with Riverpod and go_router.`
- `Configure Firebase Auth, Firestore, Storage, and Functions for this Flutter app.`
- `Write a Cloud Function for Gmail OAuth2 and syncing emails.`
- `Create onboarding UI for linking email and setting up reply tone.`
- `Build UI to display emails with tag filters.`
- `Integrate OpenAI API for smart reply suggestions.`
- `Detect PDF/DOCX attachments and summarize with AI.`
- `Add campaign tracker model and UI.`
- `Set up scheduled function for deadline reminders.`
- `Integrate YouTube/Instagram metrics via OAuth2.`
- `Write automated tests for all major features.`

---

## 🏁 Final Launch Checklist

- [ ] Firebase Project & APIs set up
- [ ] OAuth2 Apps registered
- [ ] Flutter project initialized
- [ ] Essential dependencies installed
- [ ] First run on Android, iOS, and Web
- [ ] Commit + push boilerplate to GitHub
- [ ] Theme/Design System Showcase live and referenced in all new UI work
