class Payment {
  final String id;
  final String userId;
  final String providerId;
  final String serviceId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final PaymentMethod paymentMethod;
  final String? transactionId;
  final String paymentReference;
  final double adminFee;
  final DateTime? paymentDate;
  final DateTime createdAt;
  final DateTime expiresAt;

  Payment({
    required this.id,
    required this.userId,
    required this.providerId,
    required this.serviceId,
    required this.amount,
    this.currency = 'ETB',
    required this.status,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentReference,
    this.adminFee = 100.0,
    this.paymentDate,
    required this.createdAt,
    required this.expiresAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      providerId: json['providerId'],
      serviceId: json['serviceId'],
      amount: (json['amount'] ?? 100.0).toDouble(),
      currency: json['currency'] ?? 'ETB',
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentMethod'],
        orElse: () => PaymentMethod.telebirr,
      ),
      transactionId: json['transactionId'],
      paymentReference: json['paymentReference'],
      adminFee: (json['adminFee'] ?? 100.0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'providerId': providerId,
      'serviceId': serviceId,
      'amount': amount,
      'currency': currency,
      'status': status.toString().split('.').last,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'transactionId': transactionId,
      'paymentReference': paymentReference,
      'adminFee': adminFee,
      'paymentDate': paymentDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

enum PaymentStatus { pending, completed, failed, refunded }

enum PaymentMethod { telebirr, cbe_birr, awash_birr, bank_transfer, cash }
