import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import '../models/chat_model.dart';
import '../services/payment_service.dart';

class PaymentProvider with ChangeNotifier {
  List<Payment> _payments = [];
  bool _isLoading = false;
  String? _error;
  Payment? _currentPayment;
  Connection? _currentConnection;

  List<Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Payment? get currentPayment => _currentPayment;
  Connection? get currentConnection => _currentConnection;

  Future<bool> initiatePayment(
    String token,
    String serviceId,
    PaymentMethod paymentMethod,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await PaymentService.initiatePayment(
        token,
        serviceId,
        paymentMethod,
      );

      _currentPayment = Payment.fromJson(response['payment']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmPayment(
    String token,
    String paymentId,
    String transactionId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await PaymentService.confirmPayment(
        token,
        paymentId,
        transactionId,
      );

      _currentConnection = Connection.fromJson(response['connection']);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> checkAccess(
    String token,
    String providerId,
    String serviceId,
  ) async {
    try {
      final response = await PaymentService.checkAccess(
        token,
        providerId,
        serviceId,
      );
      return response['hasAccess'] ?? false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadPaymentHistory(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await PaymentService.getPaymentHistory(token);
      _payments = data.map((json) => Payment.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String> processPayment(
    PaymentMethod method,
    double amount,
    String reference,
  ) async {
    return await PaymentService.processPayment(method, amount, reference);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentPayment() {
    _currentPayment = null;
    notifyListeners();
  }
}
