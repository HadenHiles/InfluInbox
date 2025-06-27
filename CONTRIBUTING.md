# Contributing to InfluInbox

Thank you for your interest in contributing to InfluInbox! We welcome contributions from the community and are grateful for your support in making this project better.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Code Style Guidelines](#code-style-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)
- [Issue Reporting](#issue-reporting)

## 🤝 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to [conduct@influinbox.com](mailto:conduct@influinbox.com).

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Git](https://git-scm.com/downloads)
- [Android Studio](https://developer.android.com/studio) and/or [Xcode](https://developer.apple.com/xcode/)
- A code editor (VS Code, Android Studio, or IntelliJ recommended)

### Useful Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Code Style](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)

## 🛠 Development Setup

1. **Fork the Repository**

   ```bash
   # Click the "Fork" button on GitHub, then clone your fork
   git clone https://github.com/yourusername/InfluInbox.git
   cd InfluInbox
   ```

2. **Add Upstream Remote**

   ```bash
   git remote add upstream https://github.com/hadenhiles/InfluInbox.git
   ```

3. **Install Dependencies**

   ```bash
   flutter pub get
   ```

4. **Verify Installation**

   ```bash
   flutter doctor
   flutter test
   ```

5. **Run the App**
   ```bash
   flutter run
   ```

## 🔄 Making Changes

### Branch Naming Convention

Create a new branch for your feature or bugfix:

```bash
git checkout -b feature/your-feature-name
git checkout -b bugfix/issue-description
git checkout -b hotfix/critical-fix
```

### Branch Types

- `feature/` - New features or enhancements
- `bugfix/` - Bug fixes
- `hotfix/` - Critical fixes that need immediate attention
- `docs/` - Documentation improvements
- `refactor/` - Code refactoring without functional changes

### Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**

```bash
feat(auth): add Google OAuth integration
fix(email): resolve parsing issue with HTML emails
docs(readme): update installation instructions
test(widgets): add unit tests for EmailCard component
```

## 📝 Pull Request Process

1. **Update Your Branch**

   ```bash
   git checkout main
   git pull upstream main
   git checkout your-branch-name
   git rebase main
   ```

2. **Run Tests and Linting**

   ```bash
   flutter test
   flutter analyze
   dart format --set-exit-if-changed .
   ```

3. **Create Pull Request**
   - Use a clear and descriptive title
   - Reference any related issues (`Closes #123`)
   - Provide a detailed description of changes
   - Include screenshots for UI changes
   - Ensure all checks pass

### Pull Request Template

```markdown
## Description

Brief description of changes made.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Screenshots (if applicable)

Add screenshots to help explain your changes.

## Checklist

- [ ] Code follows the style guidelines
- [ ] Self-review completed
- [ ] Code is commented where necessary
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No new warnings or errors
```

## 🎨 Code Style Guidelines

### Dart/Flutter Conventions

1. **Use `dart format`** to format your code:

   ```bash
   dart format .
   ```

2. **Follow Effective Dart guidelines:**

   - Use `lowerCamelCase` for variables, functions, and parameters
   - Use `UpperCamelCase` for classes, enums, typedefs
   - Use `lowercase_with_underscores` for file names
   - Use `SCREAMING_CAPS` for constants

3. **Widget Structure:**

   ```dart
   class MyWidget extends StatelessWidget {
     const MyWidget({
       super.key,
       required this.title,
       this.subtitle,
     });

     final String title;
     final String? subtitle;

     @override
     Widget build(BuildContext context) {
       return Container(
         // Widget implementation
       );
     }
   }
   ```

4. **Import Organization:**

   ```dart
   // Dart imports
   import 'dart:async';
   import 'dart:io';

   // Flutter imports
   import 'package:flutter/material.dart';
   import 'package:flutter/services.dart';

   // Package imports
   import 'package:provider/provider.dart';
   import 'package:http/http.dart' as http;

   // Local imports
   import '../models/user.dart';
   import '../services/api_service.dart';
   ```

### File Organization

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── routes.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── email/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── shared/
│   ├── widgets/
│   ├── services/
│   └── models/
└── l10n/
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

### Test Types

1. **Unit Tests** - Test individual functions and classes
2. **Widget Tests** - Test individual widgets
3. **Integration Tests** - Test complete user flows

### Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/your_widget.dart';

void main() {
  group('YourWidget', () {
    testWidgets('should display title correctly', (WidgetTester tester) async {
      // Arrange
      const title = 'Test Title';

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: YourWidget(title: title),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
    });
  });
}
```

## 📚 Documentation

- Update README.md for significant changes
- Add inline comments for complex logic
- Document public APIs using dart doc comments:

````dart
/// Calculates the rate for an influencer based on their metrics.
///
/// Takes into account follower count, engagement rate, and content type.
/// Returns the suggested rate in USD.
///
/// Example:
/// ```dart
/// final rate = calculateRate(
///   followers: 10000,
///   engagementRate: 0.05,
///   contentType: ContentType.post,
/// );
/// ```
double calculateRate({
  required int followers,
  required double engagementRate,
  required ContentType contentType,
}) {
  // Implementation
}
````

## 🐛 Issue Reporting

### Before Creating an Issue

1. Search existing issues to avoid duplicates
2. Check if the issue exists in the latest version
3. Provide a minimal reproduction case

### Bug Report Template

```markdown
**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:

1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment:**

- Device: [e.g. iPhone 12, Pixel 5]
- OS: [e.g. iOS 15.0, Android 12]
- Flutter Version: [e.g. 3.0.0]
- App Version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
```

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
A clear and concise description of what the problem is.

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions.

**Additional context**
Add any other context or screenshots about the feature request here.
```

## 🏷 Labels and Milestones

### Issue Labels

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `priority:high` - High priority issues
- `priority:medium` - Medium priority issues
- `priority:low` - Low priority issues

## 🎉 Recognition

Contributors will be recognized in:

- GitHub contributors list
- Release notes for significant contributions
- Special thanks in documentation

## ❓ Questions?

If you have questions about contributing, please:

1. Check the existing documentation
2. Search through existing issues
3. Create a new issue with the `question` label
4. Join our Discord community
5. Email us at [dev@influinbox.com](mailto:dev@influinbox.com)

Thank you for contributing to InfluInbox! 🚀
