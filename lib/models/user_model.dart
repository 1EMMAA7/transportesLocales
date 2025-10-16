class User {
  final int id;
  final String name;
  final String email;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']?['id'] ?? json['id'] ?? 0,
      name: json['user']?['name'] ?? json['name'] ?? '',
      email: json['user']?['email'] ?? json['email'] ?? '',
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }
}