/// User model for authentication and profile data
class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final List<String> connectedProviders;
  final DateTime createdAt;
  final DateTime lastSignIn;

  const UserModel({required this.id, required this.email, this.displayName, this.photoURL, required this.connectedProviders, required this.createdAt, required this.lastSignIn});

  /// Create UserModel from Firebase User
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      connectedProviders: firebaseUser.providerData.map<String>((provider) => provider.providerId).toList(),
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      lastSignIn: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'displayName': displayName, 'photoURL': photoURL, 'connectedProviders': connectedProviders, 'createdAt': createdAt.toIso8601String(), 'lastSignIn': lastSignIn.toIso8601String()};
  }

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      connectedProviders: List<String>.from(json['connectedProviders'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      lastSignIn: DateTime.parse(json['lastSignIn']),
    );
  }

  /// Create a copy with updated fields
  UserModel copyWith({String? id, String? email, String? displayName, String? photoURL, List<String>? connectedProviders, DateTime? createdAt, DateTime? lastSignIn}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      connectedProviders: connectedProviders ?? this.connectedProviders,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
    );
  }

  /// Check if user has a specific provider connected
  bool hasProvider(String providerId) {
    return connectedProviders.contains(providerId);
  }

  /// Check if user has Google connected
  bool get hasGoogle => hasProvider('google.com');

  /// Check if user has Microsoft connected
  bool get hasMicrosoft => hasProvider('microsoft.com');

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
