import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../common/admin_card.dart';
import '../common/admin_page_header.dart';
import 'product_text_field.dart';

/// Section "Thông tin chi tiết" – Modern Minimal.
///
/// Form thêm thuộc tính ở trên + danh sách dạng row 2 cột nhãn/giá trị bên dưới.
class ProductSpecificationsSection extends StatelessWidget {
  final List<Map<String, String>> specifications;
  final TextEditingController labelController;
  final TextEditingController valueController;
  final VoidCallback onAddSpecification;
  final Function(int) onRemoveSpecification;
  final bool isTablet;
  final bool isMobile;

  const ProductSpecificationsSection({
    super.key,
    required this.specifications,
    required this.labelController,
    required this.valueController,
    required this.onAddSpecification,
    required this.onRemoveSpecification,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AdminSectionTitle(
            title: 'Thông tin chi tiết',
            description:
                'Tên thuộc tính + giá trị – hiển thị ở tab thông tin sản phẩm.',
          ),
          if (isMobile) ...[
            ProductTextField(
              controller: labelController,
              label: 'Tên thuộc tính',
              hint: 'Ví dụ: Chất liệu',
              isTablet: isTablet,
            ),
            AppSpacing.gapMd,
            ProductTextField(
              controller: valueController,
              label: 'Giá trị',
              hint: 'Ví dụ: Linen 100%',
              isTablet: isTablet,
            ),
            AppSpacing.gapMd,
            SizedBox(
              width: double.infinity,
              child: AdminPrimaryButton(
                icon: Icons.add_rounded,
                  label: 'Thêm thuộc tính',
                onPressed: onAddSpecification,
              ),
            ),
          ] else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: ProductTextField(
                    controller: labelController,
                    label: 'Tên thuộc tính',
                    hint: 'Ví dụ: Chất liệu',
                    isTablet: isTablet,
                  ),
                ),
                AppSpacing.gapMd,
                Expanded(
                  flex: 2,
                  child: ProductTextField(
                    controller: valueController,
                    label: 'Giá trị',
                    hint: 'Ví dụ: Linen 100%',
                    isTablet: isTablet,
                  ),
                ),
                AppSpacing.gapMd,
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: AdminPrimaryButton(
                    icon: Icons.add_rounded,
                    label: 'Thêm',
                    onPressed: onAddSpecification,
                  ),
                ),
              ],
            ),
          ],
          if (specifications.isNotEmpty) ...[
            AppSpacing.gapLg,
            Row(
              children: [
                const Text(
                  'Danh sách thuộc tính',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.gapSm,
                AdminStatusPill.neutral(specifications.length.toString()),
              ],
            ),
            AppSpacing.gapMd,
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.adminBorder),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < specifications.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        color: AppColors.neutral100,
                      ),
                    _SpecRow(
                      label: specifications[i]['label'] ?? '',
                      value: specifications[i]['value'] ?? '',
                      isMobile: isMobile,
                      onRemove: () => onRemoveSpecification(i),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMobile;
  final VoidCallback onRemove;

  const _SpecRow({
    required this.label,
    required this.value,
    required this.isMobile,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.05,
      ),
    );
    final valueText = Text(
      value,
      style: const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
    final removeBtn = _RemoveSpecButton(onPressed: onRemove);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: isMobile
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      labelText,
                      const SizedBox(height: 4),
                      valueText,
                    ],
                  ),
                ),
                AppSpacing.gapSm,
                removeBtn,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 200, child: labelText),
                AppSpacing.gapMd,
                Expanded(child: valueText),
                AppSpacing.gapSm,
                removeBtn,
              ],
            ),
    );
  }
}

class _RemoveSpecButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _RemoveSpecButton({required this.onPressed});

  @override
  State<_RemoveSpecButton> createState() => _RemoveSpecButtonState();
}

class _RemoveSpecButtonState extends State<_RemoveSpecButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Xoá thuộc tính',
      child: SizedBox(
        width: 28,
        height: 28,
        child: Material(
          color: _hover
              ? AppColors.error.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (v) => setState(() => _hover = v),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: const Icon(
              Icons.delete_outline_rounded,
              size: 14,
              color: AppColors.error,
            ),
          ),
        ),
      ),
    );
  }
}
