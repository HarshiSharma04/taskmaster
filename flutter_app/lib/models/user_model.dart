class UserModel {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'createdAt': createdAt.toIso8601String(),
      };
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});
}
