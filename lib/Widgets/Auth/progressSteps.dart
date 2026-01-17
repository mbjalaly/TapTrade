import 'package:flutter/material.dart';
import 'package:taptrade/Utills/appColors.dart';

/// Minimal progress indicator showing current step in multi-step flow
/// Features:
/// - Minimal dot design [●●○]
/// - Animated transitions between steps
/// - Customizable colors
/// - Compact horizontal layout
class ProgressSteps extends StatelessWidget {
  final int currentStep; // 1, 2, 3
  final int totalSteps; // 3

  const ProgressSteps({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= currentStep;
        final isCurrentStep = stepNumber == currentStep;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isCurrentStep ? 12 : 8,
            height: isCurrentStep ? 12 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? AppColors.primaryColor
                  : AppColors.greyTextColor.withValues(alpha: 0.3),
            ),
          ),
        );
      }),
    );
  }
}
