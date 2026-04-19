// Modern Minimal – Hiển thị thông tin người nhận (read-only) ở step thanh toán/xác nhận.
//
// Card border 1px, tone surface + primary50 đầu icon. Definition list 2 cột.

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';

class RecipientInfoSection extends StatelessWidget {
  final String fullName;
  final String phone;
  final String address;
  final String? notes;

  const RecipientInfoSection({
    super.key,
    required this.fullName,
    required this.phone,
    required this.address,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
                Icons.person_outline_rounded,
                size: 16,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 8),
              Text(
                'Thông tin người nhận',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          AppSpacing.gapMd,
          _Row(
            icon: Icons.person_rounded,
            label: 'Họ tên',
            value: fullName,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            icon: Icons.phone_outlined,
            label: 'SĐT',
            value: phone,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            icon: Icons.location_on_outlined,
            label: 'Địa chỉ',
            value: address,
            multiline: true,
          ),
          if (notes != null && notes!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            _Row(
              icon: Icons.sticky_note_2_outlined,
              label: 'Ghi chú',
              value: notes!,
              multiline: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool multiline;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: AppColors.neutral400),
        ),
        AppSpacing.gapSm,
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        AppSpacing.gapSm,
        Expanded(
          child: Text(
            value,
            maxLines: multiline ? 3 : 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.05,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
