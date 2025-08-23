import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_model.dart';

class PaymentService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Initiate payment for service connection
  static Future<Map<String, dynamic>> initiatePayment(
    String token,
    String serviceId,
    PaymentMethod paymentMethod,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/initiate'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'serviceId': serviceId,
        'paymentMethod': paymentMethod.toString().split('.').last,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to initiate payment: ${response.body}');
    }
  }

  // Confirm payment (simulate payment gateway response)
  static Future<Map<String, dynamic>> confirmPayment(
    String token,
    String paymentId,
    String transactionId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/confirm'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'paymentId': paymentId,
        'transactionId': transactionId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to confirm payment: ${response.body}');
    }
  }

  // Check if user has access to provider contact info
  static Future<Map<String, dynamic>> checkAccess(
    String token,
    String providerId,
    String serviceId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/access/$providerId/$serviceId'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to check access: ${response.body}');
    }
  }

  // Get payment history
  static Future<List<dynamic>> getPaymentHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/history'),
      headers: _getHeaders(token: token),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['payments'];
    } else {
      throw Exception('Failed to load payment history');
    }
  }

  // Simulate different payment methods
  static Future<String> processPayment(
    PaymentMethod method,
    double amount,
    String reference,
  ) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate payment gateway response
    switch (method) {
      case PaymentMethod.telebirr:
        return 'TB${DateTime.now().millisecondsSinceEpoch}';
      case PaymentMethod.cbe_birr:
        return 'CBE${DateTime.now().millisecondsSinceEpoch}';
      case PaymentMethod.awash_birr:
        return 'AWB${DateTime.now().millisecondsSinceEpoch}';
      case PaymentMethod.bank_transfer:
        return 'BT${DateTime.now().millisecondsSinceEpoch}';
      case PaymentMethod.cash:
        return 'CASH${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  static String getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.telebirr:
        return 'TeleBirr';
      case PaymentMethod.cbe_birr:
        return 'CBE Birr';
      case PaymentMethod.awash_birr:
        return 'Awash Birr';
      case PaymentMethod.bank_transfer:
        return 'Bank Transfer';
      case PaymentMethod.cash:
        return 'Cash Payment';
    }
  }

  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(0)} ETB';
  }
}
