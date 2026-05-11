import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Step indicator checkout – Modern Minimal.
///
/// Numbered circles + step labels + connector line. Active dùng cam, completed
/// dùng xanh lá, idle dùng neutral.
class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep; // 1-4

  const CheckoutStepIndicator({super.key, required this.currentStep});

  static const _steps = <_StepInfo>[
    _StepInfo(number: 1, label: 'Giỏ hàng', icon: Icons.shopping_bag_outlined),
    _StepInfo(number: 2, label: 'Giao hàng', icon: Icons.local_shipping_outlined),
    _StepInfo(number: 3, label: 'Thanh toán', icon: Icons.payments_outlined),
    _StepInfo(number: 4, label: 'Xác nhận', icon: Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _steps.length; i++) ...[
            Expanded(
              child: _StepDot(
                step: _steps[i],
                isCompleted: currentStep > _steps[i].number,
                isActive: currentStep == _steps[i].number,
              ),
            ),
            if (i < _steps.length - 1)
              _Connector(
                isActive: currentStep > _steps[i].number,
              ),
          ],
        ],
      ),
    );
  }
}

class _StepInfo {
  final int number;
  final String label;
  final IconData icon;
  const _StepInfo({
    required this.number,
    required this.label,
    required this.icon,
  });
}

class _StepDot extends StatelessWidget {
  final _StepInfo step;
  final bool isCompleted;
  final bool isActive;

  const _StepDot({
    required this.step,
    required this.isCompleted,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    Color circleBg;
    Color circleFg;
    Color labelColor;
    Color borderColor;

    if (isCompleted) {
      circleBg = AppColors.success;
      circleFg = Colors.white;
      labelColor = AppColors.successDark;
      borderColor = AppColors.success;
    } else if (isActive) {
      circleBg = AppColors.primary500;
      circleFg = Colors.white;
      labelColor = AppColors.primary600;
      borderColor = AppColors.primary500;
    } else {
      circleBg = AppColors.surface;
      circleFg = AppColors.neutral500;
      labelColor = AppColors.textSecondary;
      borderColor = AppColors.adminBorder;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Colors.white,
                )
              : Icon(step.icon, size: 16, color: circleFg),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: labelColor,
            letterSpacing: -0.05,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool isActive;
  const _Connector({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(minWidth: 24),
        decoration: BoxDecoration(
          color: isActive ? AppColors.success : AppColors.neutral200,
          borderRadius: BorderRadius.circular(2),
        ),
        width: 60,
      ),
    );
  }
}
