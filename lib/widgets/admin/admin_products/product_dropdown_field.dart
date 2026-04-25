import 'package:flutter/material.dart';
import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Dropdown chuẩn cho form admin – Modern Minimal.
///
/// Cùng style với [ProductTextField]: label trên, border 1px, focus primary.
class ProductDropdownField<T> extends StatelessWidget {
  final T? value;
  final String label;
  final List<T> items;
  final List<String>? itemLabels;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final bool isTablet;
  final bool isMobile;
  final bool required;

  const ProductDropdownField({
    super.key,
    required this.value,
    required this.label,
    required this.items,
    this.itemLabels,
    required this.onChanged,
    this.validator,
    required this.isTablet,
    this.isMobile = false,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(label: label, required: required),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.neutral500,
          ),
          style: const TextStyle(
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 11,
            ),
            border: _border(AppColors.adminBorder),
            enabledBorder: _border(AppColors.adminBorder),
            focusedBorder: _border(AppColors.primary500, width: 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 1.5),
            errorStyle: const TextStyle(fontSize: 11.5, height: 1.2),
          ),
          menuMaxHeight: isMobile
              ? MediaQuery.of(context).size.height * 0.4
              : null,
          itemHeight: 48,
          items: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemLabel = itemLabels != null && index < itemLabels!.length
                ? itemLabels![index]
                : item.toString();
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
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
