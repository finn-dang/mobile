import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/order_model.dart';
import '../../../models/order_payment_status.dart';
import '../../../models/order_status.dart';
import '../../../services/order_service.dart';
import '../common/admin_card.dart';
import '../common/admin_dialog.dart';
import '../common/admin_page_header.dart';

/// Dialog chỉnh sửa đơn hàng – Modern Minimal.
///
/// Cho phép admin: đổi trạng thái + nhập/cập nhật ghi chú nội bộ.
/// (Các trường khác như khách hàng, sản phẩm... sửa trực tiếp DB nếu cần,
/// không hiển thị trong dialog này.)
class EditOrderDialog extends StatefulWidget {
  final OrderModel order;
  final void Function(String orderId, OrderStatus newStatus)? onStatusUpdated;

  const EditOrderDialog({
    super.key,
    required this.order,
    this.onStatusUpdated,
  });

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  final _orderService = OrderService();
  late final TextEditingController _notesController;
  late OrderStatus _selectedStatus;
  late OrderPaymentStatus _selectedPaymentStatus;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.order.status;
    _selectedPaymentStatus = widget.order.paymentStatus;
    _notesController = TextEditingController(text: widget.order.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _statusChanged => _selectedStatus != widget.order.status;
  bool get _paymentStatusChanged =>
      _selectedPaymentStatus != widget.order.paymentStatus;
  bool get _notesChanged =>
      _notesController.text.trim() != (widget.order.notes ?? '').trim();
  bool get _hasChanges => _statusChanged || _paymentStatusChanged || _notesChanged;

  Future<void> _handleSave() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Cập nhật status nếu đổi
      if (_statusChanged) {
        await _orderService.updateOrderStatus(widget.order.id, _selectedStatus);
        widget.onStatusUpdated?.call(widget.order.id, _selectedStatus);
      }

      if (_paymentStatusChanged) {
        await _orderService.updateOrderPaymentStatus(
          widget.order.id,
          _selectedPaymentStatus,
        );
      }

      // Cập nhật notes nếu đổi
      if (_notesChanged) {
        await _orderService.updateOrderNotes(
          widget.order.id,
          _notesController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật ${widget.order.orderCode}'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isCancelled = order.status == OrderStatus.cancelled;

    return AdminDialogShell(
      maxWidth: 540,
      title: 'Cập nhật đơn ${order.orderCode}',
      subtitle: 'Đổi trạng thái và ghi chú nội bộ cho đơn hàng.',
      icon: Icons.edit_note_rounded,
      onClose: _isSaving ? () {} : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Customer + total info
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        order.fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.phone,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapSm,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdminStatusPill.neutral('${order.items.length} món'),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(order.total),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          AppSpacing.gapLg,
          const AdminFieldLabel(label: 'Trạng thái', required: true),
          if (isCancelled)
            AdminInlineNotice.danger(
              'Đơn hàng đã bị huỷ, không thể đổi trạng thái.',
            )
          else
            _StatusOptions(
              selected: _selectedStatus,
              onChanged: _isSaving
                  ? null
                  : (s) => setState(() => _selectedStatus = s),
            ),

          AppSpacing.gapLg,
          const AdminFieldLabel(label: 'Trạng thái thanh toán', required: true),
          _PaymentStatusOptions(
            selected: _selectedPaymentStatus,
            onChanged: _isSaving
                ? null
                : (s) => setState(() => _selectedPaymentStatus = s),
          ),

          AppSpacing.gapLg,
          const AdminFieldLabel(label: 'Ghi chú nội bộ'),
          TextFormField(
            controller: _notesController,
            maxLines: 4,
            enabled: !_isSaving,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
            decoration: adminInputDecoration(
              hintText: 'Mã vận đơn, lưu ý đóng gói, lý do huỷ...',
            ),
          ),
          if (_hasChanges) ...[
            AppSpacing.gapMd,
            AdminInlineNotice.info(
              'Bạn có thay đổi chưa lưu. Nhấn "Lưu thay đổi" để cập nhật.',
            ),
          ],
        ],
      ),
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AdminSecondaryButton(
            label: 'Đóng',
            onPressed:
                _isSaving ? () {} : () => Navigator.of(context).pop(),
          ),
          AppSpacing.gapMd,
          _SaveButton(
            isLoading: _isSaving,
            disabled: !_hasChanges,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }

  String _formatPrice(int v) =>
      '${v.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} ₫';
}

// ---------------------------------------------------------------------------
// Status options (chips list)
// ---------------------------------------------------------------------------

class _StatusOptions extends StatelessWidget {
  final OrderStatus selected;
  final ValueChanged<OrderStatus>? onChanged;
  const _StatusOptions({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in OrderStatus.values)
          _StatusOption(
            status: s,
            isSelected: s == selected,
            onTap: onChanged == null ? null : () => onChanged!(s),
          ),
      ],
    );
  }
}

class _StatusOption extends StatelessWidget {
  final OrderStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.10) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? color : AppColors.adminBorder,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status.adminDisplayName,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textPrimary,
                letterSpacing: -0.05,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaymentStatusOptions extends StatelessWidget {
  final OrderPaymentStatus selected;
  final ValueChanged<OrderPaymentStatus>? onChanged;
  const _PaymentStatusOptions({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final s in OrderPaymentStatus.values)
          _PaymentStatusOption(
            status: s,
            isSelected: s == selected,
            onTap: onChanged == null ? null : () => onChanged!(s),
          ),
      ],
    );
  }
}

class _PaymentStatusOption extends StatelessWidget {
  final OrderPaymentStatus status;
  final bool isSelected;
  final VoidCallback? onTap;
  const _PaymentStatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.10) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? color : AppColors.adminBorder,
            width: isSelected ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              status.displayName,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textPrimary,
                letterSpacing: -0.05,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(Icons.check_rounded, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Save button (with loading + disabled state)
// ---------------------------------------------------------------------------

class _SaveButton extends StatelessWidget {
  final bool isLoading;
  final bool disabled;
  final VoidCallback onPressed;

  const _SaveButton({
    required this.isLoading,
    required this.disabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = (disabled || isLoading)
        ? AppColors.primary300
        : AppColors.primary500;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: (disabled || isLoading) ? null : onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              AppSpacing.gapSm,
              Text(
                isLoading ? 'Đang lưu...' : 'Lưu thay đổi',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
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
