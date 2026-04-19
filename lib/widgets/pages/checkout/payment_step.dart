// Modern Minimal – Step 3 (Thanh toán) trong checkout customer.
//
// Desktop 2 cột (payment methods 2/3 + recipient info 1/3); mobile stacked.
// Footer có 2 nút "Quay lại" (outline) + "Tiếp tục" (primary cam).

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/payment_method.dart';
import 'payment_methods_section.dart';
import 'recipient_info_section.dart';

class PaymentStep extends StatefulWidget {
  final VoidCallback onBack;
  final Function(PaymentMethod paymentMethod) onNext;
  final String? fullName;
  final String? phone;
  final String? address;

  const PaymentStep({
    super.key,
    required this.onBack,
    required this.onNext,
    this.fullName,
    this.phone,
    this.address,
  });

  @override
  State<PaymentStep> createState() => _PaymentStepState();
}

class _PaymentStepState extends State<PaymentStep> {
  PaymentMethod _selectedMethod = PaymentMethod.momo;

  bool get _hasRecipient =>
      widget.fullName != null &&
      widget.phone != null &&
      widget.address != null;

  Widget _buildRecipient() {
    if (!_hasRecipient) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          border: Border.all(color: AppColors.adminBorder),
        ),
        child: const Center(
          child: Text(
            'Vui lòng nhập thông tin giao hàng',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return RecipientInfoSection(
      fullName: widget.fullName!,
      phone: widget.phone!,
      address: widget.address!,
    );
  }

  Widget _buildActionBar() {
    return Row(
      children: [
        Expanded(
          child: _SecondaryButton(
            icon: Icons.arrow_back_rounded,
            label: 'Quay lại',
            onPressed: widget.onBack,
          ),
        ),
        AppSpacing.gapMd,
        Expanded(
          flex: 2,
          child: _PrimaryButton(
            icon: Icons.arrow_forward_rounded,
            label: 'Tiếp tục',
            onPressed: () => widget.onNext(_selectedMethod),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    final paymentSection = PaymentMethodsSection(
      selectedMethod: _selectedMethod,
      onMethodSelected: (m) => setState(() => _selectedMethod = m),
    );

    if (isMobile) {
      return Column(
        children: [
          if (_hasRecipient) ...[
            _buildRecipient(),
            AppSpacing.gapLg,
          ],
          paymentSection,
          AppSpacing.gapLg,
          _buildActionBar(),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: paymentSection),
            AppSpacing.gapLg,
            Expanded(child: _buildRecipient()),
          ],
        ),
        AppSpacing.gapXl,
        _buildActionBar(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Buttons
// ---------------------------------------------------------------------------

class _PrimaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.primary600 : AppColors.primary500,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.surfaceMuted : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.adminBorder),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
