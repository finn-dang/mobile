import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';

/// Quantity selector – Modern Minimal.
///
/// Bố cục: nút - / số / nút + + nhãn "Có sẵn N sản phẩm" bên cạnh.
class QuantitySelector extends StatelessWidget {
  final int value;
  final int max;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const QuantitySelector({
    super.key,
    required this.value,
    required this.max,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final canDec = enabled && value > 1;
    final canInc = enabled && value < max;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.adminBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QtyButton(
                icon: Icons.remove_rounded,
                enabled: canDec,
                onPressed: () => onChanged(value - 1),
              ),
              SizedBox(
                width: 48,
                child: Center(
                  child: Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              _QtyButton(
                icon: Icons.add_rounded,
                enabled: canInc,
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
        AppSpacing.gapMd,
        Flexible(
          child: Text(
            max > 0 ? 'Còn $max sản phẩm' : 'Hết hàng',
            style: TextStyle(
              fontSize: 12.5,
              color: max > 0
                  ? AppColors.textSecondary
                  : AppColors.error,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _QtyButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Icon(
              icon,
              size: 16,
              color:
                  enabled ? AppColors.textPrimary : AppColors.neutral300,
            ),
          ),
        ),
      ),
    );
  }
}
