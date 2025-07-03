import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/email_model.dart';

/// Provider for email list state
final emailListProvider = StateNotifierProvider<EmailListNotifier, AsyncValue<List<EmailModel>>>((ref) {
  return EmailListNotifier();
});

/// Provider for selected email
final selectedEmailProvider = StateProvider<EmailModel?>((ref) => null);

/// Provider for email search query
final emailSearchProvider = StateProvider<String>((ref) => '');

/// Provider for email filters
final emailFiltersProvider = StateProvider<EmailFilters>((ref) => const EmailFilters());

/// Email list notifier
class EmailListNotifier extends StateNotifier<AsyncValue<List<EmailModel>>> {
  EmailListNotifier() : super(const AsyncValue.loading()) {
    loadEmails();
  }

  /// Load emails from the server
  Future<void> loadEmails() async {
    try {
      state = const AsyncValue.loading();

      // TODO: Implement actual email fetching from Gmail/Outlook APIs
      // For now, return mock data
      final emails = await _fetchMockEmails();

      state = AsyncValue.data(emails);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Refresh email list
  Future<void> refreshEmails() async {
    await loadEmails();
  }

  /// Mark email as read
  Future<void> markAsRead(String emailId) async {
    final currentState = state;
    if (currentState is AsyncData<List<EmailModel>>) {
      final emails = currentState.value;
      final updatedEmails = emails.map((email) {
        if (email.id == emailId) {
          return email.copyWith(isRead: true);
        }
        return email;
      }).toList();

      state = AsyncValue.data(updatedEmails);

      // TODO: Update on server
    }
  }

  /// Mark email as starred
  Future<void> toggleStarred(String emailId) async {
    final currentState = state;
    if (currentState is AsyncData<List<EmailModel>>) {
      final emails = currentState.value;
      final updatedEmails = emails.map((email) {
        if (email.id == emailId) {
          return email.copyWith(isStarred: !email.isStarred);
        }
        return email;
      }).toList();

      state = AsyncValue.data(updatedEmails);

      // TODO: Update on server
    }
  }

  /// Delete email
  Future<void> deleteEmail(String emailId) async {
    final currentState = state;
    if (currentState is AsyncData<List<EmailModel>>) {
      final emails = currentState.value;
      final updatedEmails = emails.where((email) => email.id != emailId).toList();

      state = AsyncValue.data(updatedEmails);

      // TODO: Delete on server
    }
  }

  /// Search emails
  Future<void> searchEmails(String query) async {
    try {
      state = const AsyncValue.loading();

      // TODO: Implement actual search
      final emails = await _fetchMockEmails();
      final filteredEmails = emails.where((email) {
        return email.subject.toLowerCase().contains(query.toLowerCase()) || email.from.toLowerCase().contains(query.toLowerCase()) || email.bodyPlainText.toLowerCase().contains(query.toLowerCase());
      }).toList();

      state = AsyncValue.data(filteredEmails);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Mock email data for development
  Future<List<EmailModel>> _fetchMockEmails() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return [
      EmailModel(
        id: '1',
        threadId: 'thread_1',
        from: 'john.doe@example.com',
        fromName: 'John Doe',
        to: ['user@example.com'],
        cc: [],
        bcc: [],
        subject: 'Welcome to InfluInbox!',
        body: '<p>Welcome to InfluInbox! This is your first email.</p>',
        bodyPlainText: 'Welcome to InfluInbox! This is your first email.',
        receivedAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        isStarred: true,
        isImportant: true,
        labels: ['inbox', 'important'],
        attachments: [],
        provider: 'gmail',
      ),
      EmailModel(
        id: '2',
        threadId: 'thread_2',
        from: 'newsletter@company.com',
        fromName: 'Company Newsletter',
        to: ['user@example.com'],
        cc: [],
        bcc: [],
        subject: 'Weekly Newsletter - Tech Updates',
        body: '<p>Here are this week\'s tech updates...</p>',
        bodyPlainText: 'Here are this week\'s tech updates...',
        receivedAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        isStarred: false,
        isImportant: false,
        labels: ['inbox', 'newsletters'],
        attachments: [],
        provider: 'outlook',
      ),
      EmailModel(
        id: '3',
        threadId: 'thread_3',
        from: 'team@project.com',
        fromName: 'Project Team',
        to: ['user@example.com'],
        cc: ['manager@project.com'],
        bcc: [],
        subject: 'Project Update - Milestone Reached',
        body: '<p>Great news! We\'ve reached our project milestone.</p>',
        bodyPlainText: 'Great news! We\'ve reached our project milestone.',
        receivedAt: DateTime.now().subtract(const Duration(hours: 6)),
        isRead: false,
        isStarred: false,
        isImportant: true,
        labels: ['inbox', 'work'],
        attachments: [
          const EmailAttachment(
            id: 'att_1',
            filename: 'milestone_report.pdf',
            mimeType: 'application/pdf',
            size: 1024576, // 1MB
          ),
        ],
        provider: 'gmail',
      ),
    ];
  }
}

/// Email filters model
class EmailFilters {
  final bool showUnreadOnly;
  final bool showStarredOnly;
  final bool showImportantOnly;
  final List<String> selectedLabels;
  final String? provider;

  const EmailFilters({this.showUnreadOnly = false, this.showStarredOnly = false, this.showImportantOnly = false, this.selectedLabels = const [], this.provider});

  EmailFilters copyWith({bool? showUnreadOnly, bool? showStarredOnly, bool? showImportantOnly, List<String>? selectedLabels, String? provider}) {
    return EmailFilters(
      showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
      showStarredOnly: showStarredOnly ?? this.showStarredOnly,
      showImportantOnly: showImportantOnly ?? this.showImportantOnly,
      selectedLabels: selectedLabels ?? this.selectedLabels,
      provider: provider ?? this.provider,
    );
  }
}
