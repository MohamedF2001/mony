class AuthUser {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final bool isPremium;
  final DateTime? premiumUntil;
  final String subscriptionType;

  AuthUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.avatar,
    required this.createdAt,
    this.isPremium = false,
    this.premiumUntil,
    this.subscriptionType = 'none',
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['_id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isPremium: json['isPremium'] as bool? ?? false,
      premiumUntil: json['premiumUntil'] != null 
          ? DateTime.parse(json['premiumUntil'] as String) 
          : null,
      subscriptionType: json['subscriptionType'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'premiumUntil': premiumUntil?.toIso8601String(),
      'subscriptionType': subscriptionType,
    };
  }
}
