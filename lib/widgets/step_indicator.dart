import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;

            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index == totalSteps - 1 ? 0 : 8,
                ),
                decoration: BoxDecoration(
                  color: (isCompleted && isActive)
                      ? AppTheme.accentGold
                      : AppTheme.borderGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Step Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final isCompleted = index < currentStep;
            final isActive = index == currentStep;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppTheme.accentGold
                          : isActive
                              ? AppTheme.accentGold
                              : AppTheme.borderGray,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: AppTheme.primaryBlack,
                            )
                          : Text(
                              '${index + 1}',
                              style: AppTheme.bodySmall.copyWith(
                                color: isActive
                                    ? AppTheme.primaryBlack
                                    : AppTheme.textGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stepTitles[index],
                    style: AppTheme.bodySmall.copyWith(
                      color: (isCompleted && isActive)
                          ? AppTheme.primaryWhite
                          : AppTheme.textGray,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
