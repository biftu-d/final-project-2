import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/payment_model.dart';
import '../../models/service_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../services/payment_service.dart';
import '../chat/chat_screen.dart';

class PaymentScreen extends StatefulWidget {
  final ServiceModel service;

  const PaymentScreen({super.key, required this.service});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.telebirr;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Connect to Provider',
          style: AppTheme.headingSmall,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.work_rounded,
                          color: AppTheme.accentGold,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.service.serviceName,
                              style: AppTheme.headingSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.service.providerName,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: AppTheme.accentGold,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.service.rating.toStringAsFixed(1)} (${widget.service.totalReviews})',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.textGray,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppTheme.accentGold,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pay 100 ETB to unlock contact information and start chatting with the provider',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primaryWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Amount
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Connection Fee',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Connection',
                        style: AppTheme.bodyMedium,
                      ),
                      Text(
                        PaymentService.formatCurrency(100),
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: AppTheme.borderGray),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        PaymentService.formatCurrency(100),
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Method',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  ...PaymentMethod.values.map((method) {
                    return _buildPaymentMethodTile(method);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Pay Button
            CustomButton(
              text: _isProcessing
                  ? 'Processing...'
                  : 'Pay ${PaymentService.formatCurrency(100)}',
              onPressed: _isProcessing
                  ? null
                  : () => _processPayment(authProvider, paymentProvider),
              isLoading: _isProcessing || paymentProvider.isLoading,
              backgroundColor: AppTheme.accentGold,
              textColor: AppTheme.primaryBlack,
            ),

            if (paymentProvider.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppTheme.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        paymentProvider.error!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.errorRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _selectedPaymentMethod == method;
    final displayName = PaymentService.getPaymentMethodDisplayName(method);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentGold.withOpacity(0.1)
              : AppTheme.primaryBlack,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.accentGold : AppTheme.borderGray,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(method),
              color: isSelected ? AppTheme.accentGold : AppTheme.textGray,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                displayName,
                style: AppTheme.bodyMedium.copyWith(
                  color:
                      isSelected ? AppTheme.accentGold : AppTheme.primaryWhite,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.accentGold,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.telebirr:
        return Icons.phone_android_rounded;
      case PaymentMethod.cbe_birr:
        return Icons.account_balance_rounded;
      case PaymentMethod.awash_birr:
        return Icons.account_balance_wallet_rounded;
      case PaymentMethod.bank_transfer:
        return Icons.account_balance_rounded;
      case PaymentMethod.cash:
        return Icons.money_rounded;
    }
  }

  Future<void> _processPayment(
    AuthProvider authProvider,
    PaymentProvider paymentProvider,
  ) async {
    if (authProvider.token == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Step 1: Initiate payment
      final success = await paymentProvider.initiatePayment(
        authProvider.token!,
        widget.service.id,
        _selectedPaymentMethod,
      );

      if (!success || paymentProvider.currentPayment == null) {
        throw Exception('Failed to initiate payment');
      }

      // Step 2: Simulate payment processing
      final transactionId = await paymentProvider.processPayment(
        _selectedPaymentMethod,
        100.0,
        paymentProvider.currentPayment!.paymentReference,
      );

      // Step 3: Confirm payment
      final confirmed = await paymentProvider.confirmPayment(
        authProvider.token!,
        paymentProvider.currentPayment!.id,
        transactionId,
      );

      if (confirmed && mounted) {
        // Navigate to chat screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: paymentProvider.currentConnection!.chatId,
              providerName: widget.service.providerName,
              serviceName: widget.service.serviceName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}
