class ServiceModel {
  final String id;
  final String name;
  final String providerId;
  final String providerName;
  final String serviceName;
  final String category;
  final String description;
  final String location;
  final double rating;
  final int totalReviews;
  final String priceRange;
  final List<String> availability;
  final String verificationStatus;
  final String? image;
  final String? businessLicense;
  final int experience;
  final bool isAvailable;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final double? distance;
  final String status;

  ServiceModel({
    required this.id,
    required this.name,
    required this.providerId,
    required this.providerName,
    required this.serviceName,
    required this.category,
    required this.description,
    required this.location,
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.priceRange,
    required this.availability,
    required this.verificationStatus,
    this.image,
    this.businessLicense,
    required this.experience,
    this.isAvailable = true,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.distance,
    required this.status,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      providerId: json['providerId'] is String
          ? json['providerId']
          : json['providerId']?['_id']?.toString() ?? '',
      providerName: json['providerId']?['name'] ?? json['providerName'] ?? '',
      serviceName: json['serviceName'],
      category: json['category'],
      description: json['description'],
      location: json['location'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: (json['totalReviews'] is int)
          ? json['totalReviews']
          : int.tryParse(json['totalReviews']?.toString() ?? '0') ?? 0,
      priceRange: json['priceRange'],
      availability: (json['availability'] != null)
          ? List<String>.from(
              (json['availability'] as List).map((e) => e.toString()))
          : [],
      verificationStatus: json['verificationStatus'] ?? 'pending',
      image: json['image']?.toString(),
      businessLicense: json['businessLicense'],
      experience: (json['experience'] is int)
          ? json['experience']
          : int.tryParse(json['experience']?.toString() ?? '0') ?? 0,
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      latitude: json['coordinates']?['latitude']?.toDouble(),
      longitude: json['coordinates']?['longitude']?.toDouble(),
      distance: json['distance']?.toDouble(),
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'serviceName': serviceName,
      'category': category,
      'description': description,
      'location': location,
      'rating': rating,
      'totalReviews': totalReviews,
      'priceRange': priceRange,
      'availability': availability,
      'image': image,
      'businessLicense': businessLicense,
      'experience': experience,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      if (latitude != null && longitude != null)
        'coordinates': {
          'latitude': latitude,
          'longitude': longitude,
        },
      if (distance != null) 'distance': distance,
    };
  }
}
