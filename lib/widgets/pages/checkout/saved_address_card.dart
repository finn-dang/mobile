// Modern Minimal – Card hiển thị 1 địa chỉ đã lưu trong checkout customer.
//
// Border 1px + radius lg, hover đổi border cam, có nút "Dùng" outline.

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/address_model.dart';

class SavedAddressCard extends StatefulWidget {
  final AddressModel address;
  final VoidCallback onSelect;

  const SavedAddressCard({
    super.key,
    required this.address,
    required this.onSelect,
  });

  @override
  State<SavedAddressCard> createState() => _SavedAddressCardState();
}

class _SavedAddressCardState extends State<SavedAddressCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.address;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _hover ? AppColors.primary50 : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: _hover ? AppColors.primary300 : AppColors.adminBorder,
            width: _hover ? 1.2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primary600,
              ),
            ),
            AppSpacing.gapMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          a.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                          border:
                              Border.all(color: AppColors.adminBorder),
                        ),
                        child: Text(
                          a.phone,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                            letterSpacing: -0.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  if (a.notes != null && a.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.sticky_note_2_outlined,
                          size: 11,
                          color: AppColors.neutral400,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            a.notes!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.neutral500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.gapSm,
            _UseButton(onPressed: widget.onSelect),
          ],
        ),
      ),
    );
  }
}

class _UseButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _UseButton({required this.onPressed});

  @override
  State<_UseButton> createState() => _UseButtonState();
}

class _UseButtonState extends State<_UseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.primary500 : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: _hover ? AppColors.primary500 : AppColors.primary300,
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            'Dùng',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: _hover ? Colors.white : AppColors.primary600,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}
