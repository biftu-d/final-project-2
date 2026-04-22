class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String? avatar;
  final String? profilePicture;
  final String? nationalId;
  final String? bio;
  final UserRole role;
  final DateTime createdAt;
  final int totalBookings;
  final double rating;
  final String servicesStatus;
  final String? verificationStatus; // 'pending', 'approved', 'rejected'
  final bool? isAvailable;
  final String? rejectionReason;
  final int? resubmissionCount;
  final int totalReviews;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    this.avatar,
    this.profilePicture,
    this.nationalId,
    this.bio,
    required this.role,
    required this.createdAt,
    this.totalBookings = 0,
    required this.rating,
    required this.servicesStatus,
    this.verificationStatus,
    this.isAvailable,
    this.rejectionReason,
    this.resubmissionCount,
    this.totalReviews = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      avatar: json['avatar'],
      profilePicture: json['profilePicture'],
      nationalId: json['nationalId'],
      bio: json['bio'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.user,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      totalBookings: json['totalBookings'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      servicesStatus: json['servicesStatus'] ?? 'Inactive',
      verificationStatus: json['verificationStatus'], // backend field
      isAvailable: json['isAvailable'],
      rejectionReason: json['rejectionReason'],
      resubmissionCount: json['resubmissionCount'],
      totalReviews: json['totalReviews'] ?? 0,
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
      'profilePicture': profilePicture,
      'nationalId': nationalId,
      'bio': bio,
      'role': role.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'totalBookings': totalBookings,
      'verificationStatus': verificationStatus,
      'isAvailable': isAvailable,
      'rejectionReason': rejectionReason,
      'resubmissionCount': resubmissionCount,
      'rating': rating,
      'totalReviews': totalReviews,
    };
  }
}

enum UserRole { user, provider }
