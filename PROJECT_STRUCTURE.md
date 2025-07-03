# InfluInbox Project Structure

This document describes the organized folder structure for the InfluInbox Flutter application.

## 📁 Folder Structure

```text
lib/
├── config/                 # Configuration files
│   └── oauth_config.dart   # OAuth configuration for development/production
├── examples/               # Example pages and demos
│   ├── firebase_example_page.dart
│   └── oauth_example.dart
├── features/               # Feature-based modules
│   ├── auth/              # Authentication feature
│   │   └── auth_page.dart
│   ├── dashboard/         # Dashboard feature
│   │   └── dashboard_page.dart
│   ├── email/             # Email management feature
│   └── settings/          # Settings feature
├── models/                # Data models
│   ├── user_model.dart    # User data model
│   └── email_model.dart   # Email data model
├── providers/             # Riverpod state management
│   ├── auth_provider.dart # Authentication state
│   └── email_provider.dart # Email state
├── services/              # Business logic and external services
│   └── firebase_services.dart # Firebase integration
├── utils/                 # Utility functions and constants
│   ├── constants.dart     # App constants
│   ├── date_utils.dart    # Date/time utilities
│   └── string_utils.dart  # String manipulation utilities
├── widgets/               # Reusable UI components
│   ├── email_list_item.dart # Email list item widget
│   └── common_widgets.dart  # Common UI widgets
├── firebase_options.dart  # Firebase configuration
└── main.dart             # App entry point
```

## 🏗️ Architecture Overview

### Feature-Based Architecture

The app follows a feature-based architecture where each major feature has its own folder containing:

- UI pages/screens
- Feature-specific widgets
- Feature-specific logic

### State Management

Using **Riverpod** for state management with providers organized by domain:

- `auth_provider.dart` - Authentication state
- `email_provider.dart` - Email data and operations

### Models

Data models with:

- JSON serialization/deserialization
- Copy methods for immutability
- Business logic helpers

### Services

External service integrations:

- Firebase services (Auth, Firestore, Storage, etc.)
- API clients (Gmail, Outlook)
- Local storage services

### Utils

Utility functions and constants:

- App-wide constants
- Helper functions
- Common utilities

### Widgets

Reusable UI components that can be used across features.

## 🚀 Getting Started

### Current Implementation Status

#### ✅ Completed

- Project structure setup
- Firebase integration
- OAuth configuration (Google & Microsoft)
- Basic authentication flow
- User and Email models
- State management setup
- Common widgets and utilities

#### 🚧 In Progress

- Email feature implementation
- Settings feature
- Analytics dashboard

#### 📋 Todo

- Gmail API integration
- Outlook API integration
- Offline support
- Push notifications
- Advanced email features

## 📖 Usage Examples

### Adding a New Feature

1. Create a new folder in `lib/features/`
2. Add feature-specific pages and widgets
3. Create a provider in `lib/providers/` if needed
4. Add models in `lib/models/` if needed
5. Update routing in `main.dart`

### Creating a New Model

```dart
// lib/models/my_model.dart
class MyModel {
  final String id;
  final String name;
  
  const MyModel({required this.id, required this.name});
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'],
      name: json['name'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

### Adding a New Provider

```dart
// lib/providers/my_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myProvider = StateNotifierProvider<MyNotifier, MyState>((ref) {
  return MyNotifier();
});

class MyNotifier extends StateNotifier<MyState> {
  MyNotifier() : super(MyState.initial());
  
  // Add methods here
}
```

### Creating Reusable Widgets

```dart
// lib/widgets/my_widget.dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  
  const MyWidget({
    Key? key,
    required this.title,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
```

## 🛠️ Development Guidelines

### File Naming

- Use snake_case for file names
- Be descriptive but concise
- Include the widget/class type in the name (e.g., `auth_page.dart`, `user_model.dart`)

### Code Organization

- Keep files focused on a single responsibility
- Use barrel exports when appropriate
- Group related functionality together

### State Management Guidelines

- Use Riverpod providers for state management
- Keep providers focused on specific domains
- Use StateNotifier for complex state logic

### UI Development

- Create reusable widgets in the `widgets/` folder
- Use the app's design system (colors, spacing, etc.)
- Follow Material Design guidelines

## 🔧 Configuration

### OAuth Configuration

The `oauth_config.dart` file manages OAuth scopes for development and production:

```dart
// Development mode (limited scopes)
static const bool isDevelopment = true;

// Switch to false for production with full Gmail access
static const bool isDevelopment = false;
```

### Constants

App-wide constants are defined in `utils/constants.dart`:

- API endpoints
- UI constants
- Feature flags
- Error messages

## 📱 Running the App

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build for production
flutter build apk --release  # Android
flutter build ipa --release  # iOS
```

## 🤝 Contributing

When contributing to this project:

1. Follow the established folder structure
2. Add appropriate tests for new features
3. Update this README if adding new architectural patterns
4. Use consistent code formatting
5. Write clear commit messages

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Material Design Guidelines](https://material.io/design)
