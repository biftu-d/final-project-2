import 'dart:convert';
import 'package:http/http.dart' as http;

class ChapaService {
  static const String _baseUrl = 'https://api.chapa.co/v1';
  static const String _secretKey =
      'CHASECK_TEST-your-secret-key-here'; // Replace with actual key

  static Map<String, String> _getHeaders() {
    return {
      'Authorization': 'Bearer $_secretKey',
      'Content-Type': 'application/json',
    };
  }

  // Initialize payment
  static Future<Map<String, dynamic>> initializePayment({
    required String email,
    required double amount,
    required String firstName,
    required String lastName,
    required String txRef,
    String? callbackUrl,
    String? returnUrl,
    String currency = 'ETB',
    Map<String, dynamic>? customization,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/initialize'),
        headers: _getHeaders(),
        body: jsonEncode({
          'amount': amount.toString(),
          'currency': currency,
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'tx_ref': txRef,
          'callback_url': callbackUrl,
          'return_url': returnUrl,
          'customization': customization ??
              {
                'title': 'ProMatch Payment',
                'description': 'Service booking payment',
              },
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Payment initialization failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Chapa payment error: $e');
    }
  }

  // Verify payment
  static Future<Map<String, dynamic>> verifyPayment(String txRef) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transaction/verify/$txRef'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Payment verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Chapa verification error: $e');
    }
  }

  // Transfer money to provider (payout)
  static Future<Map<String, dynamic>> transferMoney({
    required String accountName,
    required String accountNumber,
    required double amount,
    required String reference,
    required String bankCode,
    String currency = 'ETB',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transfer'),
        headers: _getHeaders(),
        body: jsonEncode({
          'account_name': accountName,
          'account_number': accountNumber,
          'amount': amount.toString(),
          'reference': reference,
          'bank_code': bankCode,
          'currency': currency,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Transfer failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Chapa transfer error: $e');
    }
  }

  // Get banks list
  static Future<List<dynamic>> getBanks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/banks'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to get banks: ${response.body}');
      }
    } catch (e) {
      throw Exception('Chapa banks error: $e');
    }
  }

  // Generate transaction reference
  static String generateTxRef() {
    return 'PM-${DateTime.now().millisecondsSinceEpoch}';
  }
}
