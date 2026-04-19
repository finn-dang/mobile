// Modern Minimal – Section chọn phương thức thanh toán cho checkout customer.
//
// Card border 1px wrap, mỗi method là card option có border + icon + tên +
// mô tả; selected có border cam + nền primary50 + check icon.

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/payment_method.dart';

class PaymentMethodsSection extends StatelessWidget {
  final PaymentMethod selectedMethod;
  final Function(PaymentMethod) onMethodSelected;

  const PaymentMethodsSection({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 18,
                color: AppColors.primary600,
              ),
              SizedBox(width: 8),
              Text(
                'Phương thức thanh toán',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Padding(
            padding: EdgeInsets.only(left: 26),
            child: Text(
              'Chọn cách bạn muốn thanh toán cho đơn hàng này',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          AppSpacing.gapLg,
          for (var i = 0; i < PaymentMethod.values.length; i++) ...[
            if (i > 0) AppSpacing.gapSm,
            _MethodOption(
              method: PaymentMethod.values[i],
              isSelected: selectedMethod == PaymentMethod.values[i],
              onTap: () => onMethodSelected(PaymentMethod.values[i]),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Method option card
// ---------------------------------------------------------------------------

class _MethodOption extends StatefulWidget {
  final PaymentMethod method;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodOption({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MethodOption> createState() => _MethodOptionState();
}

class _MethodOptionState extends State<_MethodOption> {
  bool _hover = false;

  ({IconData icon, Color iconBg, Color iconFg}) get _style {
    switch (widget.method) {
      case PaymentMethod.cod:
        return (
          icon: Icons.local_shipping_outlined,
          iconBg: AppColors.warningContainer,
          iconFg: AppColors.warningDark,
        );
      case PaymentMethod.momo:
        return (
          icon: Icons.qr_code_2_rounded,
          iconBg: const Color(0xFFFCE7F3),
          iconFg: const Color(0xFFA50064),
        );
      case PaymentMethod.payos:
        return (
          icon: Icons.qr_code_scanner_rounded,
          iconBg: AppColors.successContainer,
          iconFg: const Color(0xFF065F46),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style;
    final selected = widget.isSelected;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary50 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected
                ? AppColors.primary500
                : (_hover ? AppColors.primary300 : AppColors.adminBorder),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: s.iconBg,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(s.icon, size: 18, color: s.iconFg),
                  ),
                  AppSpacing.gapMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.method.name,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w600,
                            color: selected
                                ? AppColors.primary700
                                : AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.method.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapSm,
                  _CheckMark(selected: selected),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckMark extends StatelessWidget {
  final bool selected;
  const _CheckMark({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary500 : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primary500 : AppColors.adminBorder,
          width: 1.5,
        ),
      ),
      child: selected
          ? const Icon(
              Icons.check_rounded,
              size: 14,
              color: Colors.white,
            )
          : null,
    );
  }
}
