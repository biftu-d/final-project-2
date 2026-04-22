import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/payment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/payment_model.dart';
import '../../models/service_model.dart';
import '../../models/booking_model.dart';
import '../../utils/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/payment_service.dart';
import '../../services/api_service.dart';
import '../chat/chat_screen.dart';

enum PaymentFlowType { connection, bookingCompletion }

class PaymentScreen extends StatefulWidget {
  final ServiceModel? service;
  final Booking? booking;

  const PaymentScreen({super.key, this.service, this.booking})
      : assert(service != null || booking != null);

  PaymentFlowType get flowType => service != null
      ? PaymentFlowType.connection
      : PaymentFlowType.bookingCompletion;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;
  bool _chapaPaymentOpened = false;
  String? _checkoutUrl;

  // Connection flow state
  String? _pendingPaymentId;
  String? _pendingPaymentReference;

  // Booking flow state
  String? _pendingTxRef;

  // Cash payment form controllers
  final TextEditingController _cashAmountController = TextEditingController();
  final TextEditingController _paidByController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool get _isConnection => widget.flowType == PaymentFlowType.connection;
  bool get _isBooking => widget.flowType == PaymentFlowType.bookingCompletion;

  double get _amount {
    if (_isConnection) return 100.0;
    return double.tryParse(widget.booking!.price.trim()) ?? 0.0;
  }

  String get _title =>
      _isConnection ? 'Connect to Provider' : 'Complete Payment';

  String get _serviceName =>
      _isConnection ? widget.service!.serviceName : widget.booking!.serviceName;

  String get _providerName => _isConnection
      ? widget.service!.providerName
      : widget.booking!.providerName;

  @override
  void initState() {
    super.initState();
    if (_isBooking) {
      _cashAmountController.text = widget.booking!.price;
    }
  }

  @override
  void dispose() {
    _cashAmountController.dispose();
    _paidByController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getToken() =>
      Provider.of<AuthProvider>(context, listen: false).token ?? '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final paymentProvider = Provider.of<PaymentProvider>(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? AppTheme.primaryWhite : AppTheme.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _title,
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildServiceInfoCard(isDark),
            const SizedBox(height: 24),
            _buildPriceSummary(isDark),
            const SizedBox(height: 24),
            if (_selectedPaymentMethod == null && !_chapaPaymentOpened)
              _buildPaymentMethodSelector(isDark),
            if (_selectedPaymentMethod == PaymentMethod.cash && _isBooking)
              _buildCashPaymentForm(isDark),
            if (_selectedPaymentMethod != null &&
                _selectedPaymentMethod != PaymentMethod.cash &&
                !_chapaPaymentOpened &&
                !_isProcessing &&
                _checkoutUrl == null)
              _buildDigitalPaymentAction(isDark),
            if (_chapaPaymentOpened) _buildChapaVerificationSection(isDark),
            if (_selectedPaymentMethod != null &&
                _selectedPaymentMethod == PaymentMethod.cash &&
                _isConnection)
              _buildConnectionCashAction(isDark),
            _buildErrorSection(paymentProvider, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.getCardDecoration(isDark),
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
                child: Icon(
                  _isConnection
                      ? Icons.work_rounded
                      : Icons.receipt_long_rounded,
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
                      _serviceName,
                      style: isDark
                          ? AppTheme.headingSmall
                          : AppTheme.headingSmallLight,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _providerName,
                      style: (isDark
                              ? AppTheme.bodyMedium
                              : AppTheme.bodyMediumLight)
                          .copyWith(
                              color: isDark
                                  ? AppTheme.textGray
                                  : AppTheme.lightTextSecondary),
                    ),
                    if (_isConnection) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: AppTheme.accentGold),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.service!.rating.toStringAsFixed(1)} (${widget.service!.totalReviews})',
                            style: AppTheme.bodySmall.copyWith(
                              color: isDark
                                  ? AppTheme.textGray
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (_isConnection) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppTheme.accentGold, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pay 50 ETB to unlock contact information and start chatting with the provider',
                      style: AppTheme.bodySmall.copyWith(
                        color:
                            isDark ? AppTheme.primaryWhite : AppTheme.lightText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_isBooking) ...[
            const SizedBox(height: 16),
            _buildBookingDetailRow('Date',
                widget.booking!.scheduledDate.toString().split(' ')[0], isDark),
            _buildBookingDetailRow(
                'Time', widget.booking!.scheduledTime, isDark),
            _buildBookingDetailRow(
                'Location', widget.booking!.location, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: (isDark ? AppTheme.bodySmall : AppTheme.bodySmall).copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.primaryWhite : AppTheme.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.getCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isConnection ? 'Connection Fee' : 'Payment Summary',
            style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isConnection ? 'Service Connection' : 'Service Amount',
                style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
              ),
              Text(
                PaymentService.formatCurrency(_amount),
                style: (isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (_isBooking) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Platform Commission (5%)',
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark
                        ? AppTheme.textGray
                        : AppTheme.lightTextSecondary,
                  ),
                ),
                Text(
                  PaymentService.formatCurrency(_amount * 0.1),
                  style: AppTheme.bodySmall.copyWith(
                    color: isDark
                        ? AppTheme.textGray
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Divider(color: isDark ? AppTheme.borderGray : Colors.grey.shade300),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                PaymentService.formatCurrency(_amount),
                style: (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                    .copyWith(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector(bool isDark) {
    final methods = _isConnection
        ? PaymentMethod.values
        : [PaymentMethod.telebirr, PaymentMethod.cash];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.getCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
          ),
          const SizedBox(height: 16),
          ...methods.map((method) => _buildPaymentMethodTile(method, isDark)),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Continue',
            onPressed: _selectedPaymentMethod != null
                ? () => _handleMethodSelected()
                : null,
            backgroundColor: AppTheme.accentGold,
            textColor: AppTheme.primaryBlack,
          ),
        ],
      ),
    );
  }

  void _handleMethodSelected() {
    if (_selectedPaymentMethod == null) return;

    if (_isConnection) {
      if (_selectedPaymentMethod == PaymentMethod.cash) {
        setState(() {});
        _processConnectionPayment();
      } else {
        _processConnectionPayment();
      }
    } else {
      if (_selectedPaymentMethod == PaymentMethod.cash) {
        setState(() {});
      } else {
        _initializeChapaForBooking();
      }
    }
  }

  Widget _buildPaymentMethodTile(PaymentMethod method, bool isDark) {
    final isSelected = _selectedPaymentMethod == method;
    final displayName = _isBooking && method == PaymentMethod.telebirr
        ? 'Chapa Digital Payment'
        : PaymentService.getPaymentMethodDisplayName(method);
    final subtitle = _isBooking && method == PaymentMethod.telebirr
        ? 'Pay securely with Chapa'
        : method == PaymentMethod.cash
            ? 'Pay in person with cash'
            : null;

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = method),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentGold.withOpacity(0.1)
              : isDark
                  ? AppTheme.primaryBlack
                  : AppTheme.lightBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentGold
                : isDark
                    ? AppTheme.borderGray
                    : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getPaymentMethodIcon(method),
              color: isSelected
                  ? AppTheme.accentGold
                  : isDark
                      ? AppTheme.textGray
                      : AppTheme.lightTextSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: (isDark
                            ? AppTheme.bodyMedium
                            : AppTheme.bodyMediumLight)
                        .copyWith(
                      color: isSelected
                          ? AppTheme.accentGold
                          : isDark
                              ? AppTheme.primaryWhite
                              : AppTheme.lightText,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? AppTheme.textGray
                            : AppTheme.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.accentGold, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalPaymentAction(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.getCardDecoration(isDark),
          child: Column(
            children: [
              const Icon(Icons.credit_card_rounded,
                  size: 48, color: AppTheme.accentGold),
              const SizedBox(height: 16),
              Text(
                _isBooking ? 'Pay with Chapa' : 'Digital Payment',
                style:
                    isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
              ),
              const SizedBox(height: 8),
              Text(
                'You will be redirected to the secure payment page',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(
                  color:
                      isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: _isProcessing
                    ? 'Processing...'
                    : 'Pay ${PaymentService.formatCurrency(_amount)}',
                onPressed: _isProcessing
                    ? null
                    : () => _isConnection
                        ? _processConnectionPayment()
                        : _initializeChapaForBooking(),
                isLoading: _isProcessing,
                backgroundColor: AppTheme.accentGold,
                textColor: AppTheme.primaryBlack,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isProcessing
                    ? null
                    : () => setState(() {
                          _selectedPaymentMethod = null;
                          _chapaPaymentOpened = false;
                          _checkoutUrl = null;
                        }),
                child: Text(
                  'Choose Different Method',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textGray
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChapaVerificationSection(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.open_in_browser_rounded,
                  color: AppTheme.accentGold, size: 32),
              const SizedBox(height: 8),
              Text(
                'Complete your payment in the browser, then tap the button below.',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(
                  color: isDark ? AppTheme.primaryWhite : AppTheme.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text('Reopen Chapa'),
                      onPressed: () => _openChapaCheckout(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentGold,
                        side: const BorderSide(color: AppTheme.accentGold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        CustomButton(
          text: _isProcessing ? 'Verifying...' : "I've Completed Payment",
          onPressed: _isProcessing ? null : () => _verifyChapaPayment(),
          isLoading: _isProcessing,
          backgroundColor: AppTheme.successGreen,
          textColor: AppTheme.primaryWhite,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _isProcessing
              ? null
              : () => setState(() {
                    _selectedPaymentMethod = null;
                    _chapaPaymentOpened = false;
                    _checkoutUrl = null;
                    _pendingTxRef = null;
                    _pendingPaymentId = null;
                    _pendingPaymentReference = null;
                  }),
          child: Text(
            'Choose Different Method',
            style: TextStyle(
              color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCashPaymentForm(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.getCardDecoration(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Payment Details',
            style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _cashAmountController,
            label: 'Amount',
            hint: 'Enter amount',
            keyboardType: TextInputType.number,
            prefixIcon: const Icon(Icons.attach_money),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _paidByController,
            label: 'Paid By',
            hint: 'Enter payer name',
            prefixIcon: const Icon(Icons.person),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _notesController,
            label: 'Notes (Optional)',
            hint: 'Add any notes',
            maxLines: 3,
            prefixIcon: const Icon(Icons.note),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: _isProcessing ? 'Processing...' : 'Complete Cash Payment',
            onPressed: _isProcessing ? null : _completeCashPaymentForBooking,
            isLoading: _isProcessing,
            backgroundColor: AppTheme.accentGold,
            textColor: AppTheme.primaryBlack,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _isProcessing
                  ? null
                  : () => setState(() => _selectedPaymentMethod = null),
              child: Text(
                'Choose Different Method',
                style: TextStyle(
                  color:
                      isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionCashAction(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.getCardDecoration(isDark),
          child: Column(
            children: [
              const Icon(Icons.money_rounded,
                  size: 48, color: AppTheme.accentGold),
              const SizedBox(height: 16),
              Text(
                'Cash Payment',
                style:
                    isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
              ),
              const SizedBox(height: 8),
              Text(
                'Confirm your cash payment to connect with the provider',
                textAlign: TextAlign.center,
                style: AppTheme.bodySmall.copyWith(
                  color:
                      isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: _isProcessing ? 'Processing...' : 'Confirm Cash Payment',
                onPressed:
                    _isProcessing ? null : () => _processConnectionPayment(),
                isLoading: _isProcessing,
                backgroundColor: AppTheme.accentGold,
                textColor: AppTheme.primaryBlack,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _isProcessing
                    ? null
                    : () => setState(() => _selectedPaymentMethod = null),
                child: Text(
                  'Choose Different Method',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.textGray
                        : AppTheme.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorSection(PaymentProvider paymentProvider, bool isDark) {
    if (paymentProvider.error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppTheme.errorRed, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                paymentProvider.error!,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.errorRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.telebirr:
        return _isBooking
            ? Icons.credit_card_rounded
            : Icons.phone_android_rounded;
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

  // --- Connection Payment Flow ---

  Future<void> _processConnectionPayment() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider =
        Provider.of<PaymentProvider>(context, listen: false);
    if (authProvider.token == null || _selectedPaymentMethod == null) return;

    setState(() => _isProcessing = true);

    try {
      final response = await PaymentService.initiatePayment(
        authProvider.token!,
        widget.service!.id,
        _selectedPaymentMethod!,
      );

      final paymentData = response['payment'];
      if (paymentData == null) throw Exception('Failed to initiate payment');

      _pendingPaymentId = paymentData['id']?.toString();
      _pendingPaymentReference = paymentData['paymentReference']?.toString();

      final checkoutUrl = response['checkoutUrl']?.toString();

      if (_selectedPaymentMethod == PaymentMethod.cash) {
        final transactionId = 'CASH${DateTime.now().millisecondsSinceEpoch}';
        await _confirmConnectionAndNavigate(
            authProvider, paymentProvider, _pendingPaymentId!, transactionId);
        return;
      }

      if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
        setState(() {
          _checkoutUrl = checkoutUrl;
          _chapaPaymentOpened = false;
          _isProcessing = false;
        });
        await _openChapaCheckout();
        return;
      }

      if (response['warning'] != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Payment gateway unavailable: ${response['warning']}'),
            backgroundColor: AppTheme.accentGold,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted && !_chapaPaymentOpened) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _confirmConnectionAndNavigate(
    AuthProvider authProvider,
    PaymentProvider paymentProvider,
    String paymentId,
    String transactionId,
  ) async {
    final confirmed = await paymentProvider.confirmPayment(
      authProvider.token!,
      paymentId,
      transactionId,
    );

    if (confirmed && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: paymentProvider.currentConnection!.chatId,
            providerName: widget.service!.providerName,
            serviceName: widget.service!.serviceName,
          ),
        ),
      );
    } else if (!confirmed && mounted) {
      throw Exception(paymentProvider.error ?? 'Payment confirmation failed');
    }
  }

  // --- Booking Payment Flow ---

  Future<void> _initializeChapaForBooking() async {
    setState(() => _isProcessing = true);

    try {
      if (_amount <= 0) {
        _showError('Invalid booking price');
        return;
      }

      final response = await ApiService.initializeChapaPaymentForBooking(
        token: _getToken(),
        bookingId: widget.booking!.id,
        amount: _amount,
      );

      if (response['success'] == true) {
        final checkoutUrl = response['checkoutUrl']?.toString();
        final txRef = response['txRef']?.toString();

        if (checkoutUrl == null || checkoutUrl.isEmpty) {
          _showError('No checkout URL received from payment gateway');
          return;
        }

        setState(() {
          _checkoutUrl = checkoutUrl;
          _pendingTxRef = txRef;
          _chapaPaymentOpened = false;
        });

        await _openChapaCheckout();
      } else {
        _showError(response['message'] ?? 'Failed to initialize payment');
      }
    } catch (e) {
      _showError('Error initializing payment: $e');
    } finally {
      if (mounted && !_chapaPaymentOpened) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _completeCashPaymentForBooking() async {
    if (_cashAmountController.text.isEmpty || _paidByController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    final parsed = double.tryParse(_cashAmountController.text.trim());
    if (parsed == null) {
      _showError('Please enter a valid amount');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final response = await ApiService.completeCashPaymentForBooking(
        token: _getToken(),
        bookingId: widget.booking!.id,
        amount: parsed,
        paidBy: _paidByController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (response['success'] == true) {
        _showBookingSuccessAndRating('Cash payment recorded successfully!');
      } else {
        _showError(response['message'] ?? 'Failed to record payment');
      }
    } catch (e) {
      _showError('Error recording payment: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // --- Shared Logic ---

  Future<void> _openChapaCheckout() async {
    if (_checkoutUrl == null) return;
    final uri = Uri.parse(_checkoutUrl!);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          setState(() {
            _chapaPaymentOpened = true;
            _isProcessing = false;
          });
        }
      } else {
        throw Exception('Could not open payment page');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Chapa: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _verifyChapaPayment() async {
    setState(() => _isProcessing = true);

    try {
      if (_isConnection) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final paymentProvider =
            Provider.of<PaymentProvider>(context, listen: false);
        if (_pendingPaymentId == null || authProvider.token == null) return;

        final txId = _pendingPaymentReference ??
            'CHAPA${DateTime.now().millisecondsSinceEpoch}';
        await _confirmConnectionAndNavigate(
            authProvider, paymentProvider, _pendingPaymentId!, txId);
      } else {
        if (_pendingTxRef == null) return;

        final response = await ApiService.verifyBookingPayment(
          token: _getToken(),
          bookingId: widget.booking!.id,
          txRef: _pendingTxRef!,
        );

        if (response['success'] == true) {
          _showBookingSuccessAndRating(
              'Payment verified and booking completed!');
        } else {
          _showError(response['message'] ?? 'Payment verification failed');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBookingSuccessAndRating(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showRatingDialog();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        providerId: widget.booking!.providerId,
        providerName: widget.booking!.providerName,
        serviceName: widget.booking!.serviceName,
        onComplete: () {
          Navigator.pop(context); // close rating dialog
          Navigator.pop(context); // close payment screen
        },
      ),
    );
  }
}

class RatingDialog extends StatefulWidget {
  final String providerId;
  final String providerName;
  final String serviceName;
  final VoidCallback onComplete;

  const RatingDialog({
    super.key,
    required this.providerId,
    required this.providerName,
    required this.serviceName,
    required this.onComplete,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _addToFavorites = true;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      await ApiService.submitReview(
        authProvider.token!,
        widget.providerId,
        _rating,
        _commentController.text.trim(),
      );

      if (_addToFavorites) {
        await ApiService.addToFavorites(
          authProvider.token!,
          widget.providerId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit rating: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Dialog(
      backgroundColor: isDark ? AppTheme.secondaryGray : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded,
                size: 60, color: AppTheme.accentGold),
            const SizedBox(height: 16),
            Text(
              'Rate ${widget.providerName}',
              style:
                  isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.serviceName,
              style: TextStyle(
                color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 40,
                    color: AppTheme.accentGold,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: TextStyle(
                color: isDark ? AppTheme.primaryWhite : AppTheme.lightText,
              ),
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)',
                hintStyle: TextStyle(
                  color:
                      isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                ),
                filled: true,
                fillColor: isDark
                    ? AppTheme.primaryBlack.withOpacity(0.5)
                    : AppTheme.lightBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _addToFavorites,
                  onChanged: (value) =>
                      setState(() => _addToFavorites = value ?? false),
                  activeColor: AppTheme.accentGold,
                ),
                Expanded(
                  child: Text(
                    'Add to my favorites',
                    style: TextStyle(
                      color:
                          isDark ? AppTheme.primaryWhite : AppTheme.lightText,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSubmitting ? null : widget.onComplete,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textGray
                            : AppTheme.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Submit',
                    onPressed: _isSubmitting ? null : _submitRating,
                    isLoading: _isSubmitting,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
