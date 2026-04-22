import 'package:flutter/material.dart';
import '../models/service_model.dart';
import '../utils/app_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;

  const ServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: isDark
            ? AppTheme.cardDecoration
            : AppTheme.cardDecoration.copyWith(
                color: AppTheme.primaryWhite,
              ),
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
                  child: service.image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            service.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.work_rounded,
                                color: AppTheme.accentGold,
                                size: 30,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.work_rounded,
                          color: AppTheme.accentGold,
                          size: 30,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.serviceName,
                        style: (isDark
                                ? AppTheme.bodyLarge
                                : AppTheme.bodyLargeLight)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.providerName,
                        style: (isDark
                                ? AppTheme.bodyMedium
                                : AppTheme.bodyMediumLight)
                            .copyWith(
                          color: isDark
                              ? AppTheme.textGray
                              : AppTheme.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${service.rating.toStringAsFixed(1)} (${service.totalReviews})',
                            style: (isDark
                                    ? AppTheme.bodySmall
                                    : AppTheme.bodySmallLight)
                                .copyWith(
                              color: isDark
                                  ? AppTheme.textGray
                                  : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: service.isAvailable
                        ? AppTheme.successGreen.withOpacity(0.2)
                        : AppTheme.errorRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.isAvailable ? 'Available' : 'Busy',
                    style: AppTheme.bodySmall.copyWith(
                      color: service.isAvailable
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              service.description,
              style: isDark ? AppTheme.bodyMedium : AppTheme.bodyMediumLight,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppTheme.textGray,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    service.location,
                    style:
                        (isDark ? AppTheme.bodySmall : AppTheme.bodySmallLight)
                            .copyWith(
                      color: isDark
                          ? AppTheme.textGray
                          : AppTheme.lightTextSecondary,
                    ),
                  ),
                ),
                Text(
                  service.priceRange,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.category,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryWhite,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${service.experience} years exp',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryWhite,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onBookNow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'welcome.book_now'.tr(),
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
