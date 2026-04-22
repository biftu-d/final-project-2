import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Help & Support',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSupportTile(
            context,
            icon: Icons.help_outline_rounded,
            title: 'FAQ',
            subtitle: 'Frequently Asked Questions',
            onTap: () => _showFAQDialog(context),
          ),
          const SizedBox(height: 16),
          _buildSupportTile(
            context,
            icon: Icons.contact_support_rounded,
            title: 'Contact Support',
            subtitle: 'Get help from our support team',
            onTap: () => _showContactSupportDialog(context),
          ),
          const SizedBox(height: 16),
          _buildSupportTile(
            context,
            icon: Icons.report_problem_outlined,
            title: 'Report a Problem',
            subtitle: 'Report bugs or issues',
            onTap: () => _showReportProblemDialog(context),
          ),
          const SizedBox(height: 16),
          _buildSupportTile(
            context,
            icon: Icons.live_help_rounded,
            title: 'How It Works',
            subtitle: 'Learn how to use ProMatch',
            onTap: () => _showHowItWorksDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.getCardDecoration(isDark),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.accentGold, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                            .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        AppTheme.bodySmall.copyWith(color: AppTheme.textGray),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textGray,
            ),
          ],
        ),
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final faqItems = [
      {
        'question': 'How do I book a service?',
        'answer':
            'Browse services on the home screen, select a provider, tap "Book Now", choose a time slot, and complete the payment.',
      },
      {
        'question': 'How do I become a service provider?',
        'answer':
            'Sign up as a provider, complete your profile with required documents, and wait for admin approval (usually 24-48 hours).',
      },
      {
        'question': 'What payment methods are accepted?',
        'answer':
            'We accept payments through Chapa, which supports mobile money, bank transfers, and card payments.',
      },
      {
        'question': 'How do I cancel a booking?',
        'answer':
            'Go to your bookings, select the booking you want to cancel, and tap "Cancel Booking". Refunds depend on the cancellation policy.',
      },
      {
        'question': 'How do I contact a service provider?',
        'answer':
            'After booking, you can chat with your provider directly through the chat feature in the app.',
      },
      {
        'question': 'How are providers verified?',
        'answer':
            'All providers submit documents including national ID and business licenses. Our admin team reviews these before approval.',
      },
      {
        'question': 'Can I change my availability as a provider?',
        'answer':
            'Yes! Go to your dashboard and use the "Update Availability" quick action to change your working days.',
      },
      {
        'question': 'How do reviews work?',
        'answer':
            'After a service is completed, customers can rate providers on a 5-star scale and leave comments.',
      },
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'Frequently Asked Questions',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: faqItems.length,
            itemBuilder: (context, index) {
              final item = faqItems[index];
              return _FAQItem(
                question: item['question']!,
                answer: item['answer']!,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'Contact Support',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Our support team is here to help you. We typically respond within 24 hours.',
                style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: subjectController,
                label: 'Subject',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 5,
                style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                decoration: InputDecoration(
                  labelText: 'Your Message',
                  labelStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textGray,
                  ),
                  filled: true,
                  fillColor:
                      isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.email_rounded,
                        color: AppTheme.accentGold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Support',
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'support@promatch.et',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textGray,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (subjectController.text.isEmpty ||
                  messageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                ),
              );

              try {
                await ApiService.contactSupport(
                  authProvider.token!,
                  subjectController.text,
                  messageController.text,
                );

                if (!context.mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Message sent! We\'ll get back to you soon.'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            child: const Text(
              'Send',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  void _showReportProblemDialog(BuildContext context) {
    final problemController = TextEditingController();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String selectedCategory = 'Technical Issue';

    final categories = [
      'Technical Issue',
      'Payment Problem',
      'Provider Issue',
      'App Bug',
      'Other',
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor:
              isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
          title: Text(
            'Report a Problem',
            style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Help us improve ProMatch by reporting issues',
                  style:
                      isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'Category',
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.primaryBlack
                        : AppTheme.lightBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    style:
                        isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                    dropdownColor:
                        isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
                    items: categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: problemController,
                  maxLines: 5,
                  style:
                      isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
                  decoration: InputDecoration(
                    labelText: 'Describe the problem',
                    labelStyle: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textGray,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppTheme.primaryBlack
                        : AppTheme.lightBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color:
                      isDark ? AppTheme.textGray : AppTheme.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (problemController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please describe the problem'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.accentGold),
                  ),
                );

                try {
                  await ApiService.reportProblem(
                    authProvider.token!,
                    selectedCategory,
                    problemController.text,
                  );

                  if (!context.mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Problem reported! Thank you for your feedback.'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              },
              child: const Text(
                'Submit',
                style: TextStyle(color: AppTheme.accentGold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHowItWorksDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:
            isDark ? AppTheme.secondaryGray : AppTheme.lightSurface,
        title: Text(
          'How It Works',
          style: isDark ? AppTheme.headingSmall : AppTheme.headingSmallLight,
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 450,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'For Customers',
                  style: (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                    1, 'Search', 'Browse or search for services you need'),
                _buildStepItem(2, 'Choose',
                    'Select a provider based on ratings and reviews'),
                _buildStepItem(
                    3, 'Book', 'Choose a time slot and make a booking'),
                _buildStepItem(4, 'Pay', 'Secure payment through Chapa'),
                _buildStepItem(
                    5, 'Connect', 'Chat with your provider for details'),
                _buildStepItem(
                    6, 'Review', 'Rate your experience after service'),
                const SizedBox(height: 24),
                Text(
                  'For Service Providers',
                  style: (isDark ? AppTheme.bodyLarge : AppTheme.bodyLargeLight)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildStepItem(
                    1, 'Register', 'Sign up and complete your profile'),
                _buildStepItem(
                    2, 'Verify', 'Submit documents for admin approval'),
                _buildStepItem(
                    3, 'Get Approved', 'Wait for verification (24-48 hours)'),
                _buildStepItem(4, 'Receive Bookings',
                    'Get booking requests from customers'),
                _buildStepItem(5, 'Provide Service',
                    'Complete the service professionally'),
                _buildStepItem(
                    6, 'Earn & Grow', 'Build your reputation and earn money'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got It',
              style: TextStyle(color: AppTheme.accentGold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.accentGold,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '$step',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.primaryBlack,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textGray,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.primaryBlack : AppTheme.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: (isDark
                              ? AppTheme.bodyMedium
                              : AppTheme.bodyMediumLight)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.accentGold,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textGray,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
