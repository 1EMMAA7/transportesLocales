class User {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? token;
  final String? createdAt;
  final String? updatedAt;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.token,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']?['id'] ?? json['id'] ?? 0,
      fullName: json['user']?['fullName'] ?? json['fullName'] ?? json['user']?['name'] ?? json['name'] ?? '',
      email: json['user']?['email'] ?? json['email'] ?? '',
      phone: json['user']?['phone'] ?? json['phone'],
      token: json['token'],
      createdAt: json['user']?['createdAt'] ?? json['createdAt'],
      updatedAt: json['user']?['updatedAt'] ?? json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'token': token,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}