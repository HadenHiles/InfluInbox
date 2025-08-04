/// Email model for representing email messages
class EmailModel {
  final String id;
  final String threadId;
  final String from;
  final String fromName;
  final List<String> to;
  final List<String> cc;
  final List<String> bcc;
  final String subject;
  final String body;
  final String bodyPlainText;
  final DateTime receivedAt;
  final DateTime? sentAt;
  final bool isRead;
  final bool isStarred;
  final bool isImportant;
  final List<String> labels;
  final List<EmailAttachment> attachments;
  final String provider; // 'gmail' or 'outlook'

  const EmailModel({
    required this.id,
    required this.threadId,
    required this.from,
    required this.fromName,
    required this.to,
    required this.cc,
    required this.bcc,
    required this.subject,
    required this.body,
    required this.bodyPlainText,
    required this.receivedAt,
    this.sentAt,
    required this.isRead,
    required this.isStarred,
    required this.isImportant,
    required this.labels,
    required this.attachments,
    required this.provider,
  });

  /// Create from JSON
  factory EmailModel.fromJson(Map<String, dynamic> json) {
    return EmailModel(
      id: json['id'],
      threadId: json['threadId'],
      from: json['from'],
      fromName: json['fromName'] ?? json['from'],
      to: List<String>.from(json['to'] ?? []),
      cc: List<String>.from(json['cc'] ?? []),
      bcc: List<String>.from(json['bcc'] ?? []),
      subject: json['subject'] ?? '',
      body: json['body'] ?? '',
      bodyPlainText: json['bodyPlainText'] ?? '',
      receivedAt: DateTime.parse(json['receivedAt']),
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      isRead: json['isRead'] ?? false,
      isStarred: json['isStarred'] ?? false,
      isImportant: json['isImportant'] ?? false,
      labels: List<String>.from(json['labels'] ?? []),
      attachments: (json['attachments'] as List<dynamic>?)?.map((a) => EmailAttachment.fromJson(a)).toList() ?? [],
      provider: json['provider'] ?? 'gmail',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threadId': threadId,
      'from': from,
      'fromName': fromName,
      'to': to,
      'cc': cc,
      'bcc': bcc,
      'subject': subject,
      'body': body,
      'bodyPlainText': bodyPlainText,
      'receivedAt': receivedAt.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'isRead': isRead,
      'isStarred': isStarred,
      'isImportant': isImportant,
      'labels': labels,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'provider': provider,
    };
  }

  /// Create a copy with updated fields
  EmailModel copyWith({
    String? id,
    String? threadId,
    String? from,
    String? fromName,
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
    String? bodyPlainText,
    DateTime? receivedAt,
    DateTime? sentAt,
    bool? isRead,
    bool? isStarred,
    bool? isImportant,
    List<String>? labels,
    List<EmailAttachment>? attachments,
    String? provider,
  }) {
    return EmailModel(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      from: from ?? this.from,
      fromName: fromName ?? this.fromName,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      bcc: bcc ?? this.bcc,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      bodyPlainText: bodyPlainText ?? this.bodyPlainText,
      receivedAt: receivedAt ?? this.receivedAt,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
      isStarred: isStarred ?? this.isStarred,
      isImportant: isImportant ?? this.isImportant,
      labels: labels ?? this.labels,
      attachments: attachments ?? this.attachments,
      provider: provider ?? this.provider,
    );
  }

  /// Get email preview text (first 100 characters of plain text)
  String get preview {
    return bodyPlainText.length > 100 ? '${bodyPlainText.substring(0, 100)}...' : bodyPlainText;
  }

  /// Check if email has attachments
  bool get hasAttachments => attachments.isNotEmpty;

  /// Get total attachment size in bytes
  int get totalAttachmentSize {
    return attachments.fold(0, (sum, attachment) => sum + attachment.size);
  }

  @override
  String toString() {
    return 'EmailModel(id: $id, from: $from, subject: $subject)';
  }
}

/// Email attachment model
class EmailAttachment {
  final String id;
  final String filename;
  final String mimeType;
  final int size;
  final String? downloadUrl;

  const EmailAttachment({required this.id, required this.filename, required this.mimeType, required this.size, this.downloadUrl});

  /// Create from JSON
  factory EmailAttachment.fromJson(Map<String, dynamic> json) {
    return EmailAttachment(id: json['id'], filename: json['filename'], mimeType: json['mimeType'], size: json['size'], downloadUrl: json['downloadUrl']);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'filename': filename, 'mimeType': mimeType, 'size': size, 'downloadUrl': downloadUrl};
  }

  /// Get human readable file size
  String get humanReadableSize {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
    if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Check if attachment is an image
  bool get isImage => mimeType.startsWith('image/');

  /// Check if attachment is a document
  bool get isDocument {
    return mimeType.contains('pdf') || mimeType.contains('document') || mimeType.contains('text') || mimeType.contains('presentation') || mimeType.contains('spreadsheet');
  }
}
