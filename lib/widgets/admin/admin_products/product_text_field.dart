import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// TextField chuẩn cho form admin – Modern Minimal.
///
/// • Label hiển thị BÊN TRÊN ô input (nhỏ, w600) thay vì floating label rườm rà.
/// • Border 1px màu adminBorder, focus đổi sang primary500.
/// • Padding gọn, font 13.5px.
class ProductTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? Function(String?)? validator;
  final bool isTablet;
  final String? prefix;
  final String? suffix;
  final bool required;

  const ProductTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.maxLines,
    this.validator,
    required this.isTablet,
    this.prefix,
    this.suffix,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultipleLines = (maxLines ?? 1) > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          validator: validator,
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13.5,
              color: AppColors.neutral400,
            ),
            prefixText: prefix,
            suffixText: suffix,
            isDense: true,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: hasMultipleLines ? 12 : 11,
            ),
            border: _border(AppColors.adminBorder),
            enabledBorder: _border(AppColors.adminBorder),
            focusedBorder: _border(AppColors.primary500, width: 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 1.5),
            errorStyle: const TextStyle(fontSize: 11.5, height: 1.2),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// Label nhỏ phía trên field – Modern Minimal.
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    final cleanLabel = label.replaceAll(RegExp(r'\s*\*$'), '');
    final isRequired = required || label.trim().endsWith('*');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          cleanLabel,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.05,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 3),
          const Text(
            '*',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
