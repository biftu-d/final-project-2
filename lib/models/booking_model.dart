class Booking {
  final String id;
  final String userId;
  final String providerId;
  final String serviceId;
  final String serviceName;
  final String providerName;
  final String customerName;
  final DateTime scheduledDate;
  final String scheduledTime;
  final BookingStatus status;
  final String location;
  final String price;
  final String? notes;
  final String? providerPhone;
  final String? customerPhone;
  final String? providerImage;
  final String? customerImage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double? rating;
  final String? review;

  Booking({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.serviceName,
    required this.providerName,
    required this.customerName,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    required this.location,
    required this.price,
    this.notes,
    this.providerPhone,
    this.customerPhone,
    this.providerImage,
    this.customerImage,
    required this.createdAt,
    this.completedAt,
    this.rating,
    this.review,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      providerId: json['providerId'],
      serviceId: json['serviceId'],
      serviceName: json['serviceName'],
      providerName: json['providerName'],
      customerName: json['customerName'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      scheduledTime: json['scheduledTime'],
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      location: json['location'],
      price: json['price'],
      notes: json['notes'],
      providerPhone: json['providerPhone'],
      customerPhone: json['customerPhone'],
      providerImage: json['providerImage'],
      customerImage: json['customerImage'],
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      rating: json['rating']?.toDouble(),
      review: json['review'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'providerName': providerName,
      'customerName': customerName,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': scheduledTime,
      'status': status.toString().split('.').last,
      'location': location,
      'price': price,
      'notes': notes,
      'providerPhone': providerPhone,
      'customerPhone': customerPhone,
      'providerImage': providerImage,
      'customerImage': customerImage,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'rating': rating,
      'review': review,
    };
  }
}

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }
