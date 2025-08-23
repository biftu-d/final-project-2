class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? avatar;
  final UserRole role;
  final DateTime createdAt;
  final int totalBookings;
  final double rating;
  final String servicesStatus;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.avatar,
    required this.role,
    required this.createdAt,
    this.totalBookings = 0,
    required this.rating,
    required this.servicesStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      location: json['location'],
      avatar: json['avatar'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.user,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      totalBookings: json['totalBookings'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      servicesStatus: json['servicesStatus'] ?? 'Inactive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'avatar': avatar,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'totalBookings': totalBookings,
    };
  }
}

enum UserRole { user, provider }
