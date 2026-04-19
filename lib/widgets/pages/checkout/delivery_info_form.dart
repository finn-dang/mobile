// Modern Minimal – Form nhập thông tin giao hàng cho checkout customer.
//
// Card border 1px + radius xl2, dùng AdminFieldLabel/adminInputDecoration để
// đồng bộ với form admin. Các nút primary/secondary cùng tone Modern Minimal.

import 'package:flutter/material.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/address_model.dart';
import '../../../../services/address_service.dart';
import '../../../../services/auth_service.dart';
import '../../admin/common/admin_dialog.dart';

class DeliveryInfoForm extends StatefulWidget {
  final Function(String fullName, String phone, String address, String? notes) onNext;

  const DeliveryInfoForm({
    super.key,
    required this.onNext,
  });

  @override
  State<DeliveryInfoForm> createState() => DeliveryInfoFormState();
}

class DeliveryInfoFormState extends State<DeliveryInfoForm> {
  final _formKey = GlobalKey<FormState>();
  final _addressService = AddressService();
  final _authService = AuthService();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;

  /// Load address data into form (gọi từ checkout_page khi user chọn địa chỉ).
  Future<void> loadAddress(String addressId) async {
    try {
      final addresses = await _addressService.getAddressesOnce();
      final address = addresses.firstWhere((a) => a.id == addressId);

      setState(() {
        _fullNameController.text = address.fullName;
        _phoneController.text = address.phone;
        _addressController.text = address.address;
        _notesController.text = address.notes ?? '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải địa chỉ: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw 'Vui lòng đăng nhập';
      }

      // Check if phone number already exists
      final existingAddresses = await _addressService.getAddressesOnce();
      final phoneNumber = _phoneController.text.trim();
      final phoneExists = existingAddresses.any(
        (address) => address.phone == phoneNumber,
      );

      if (phoneExists) {
        throw 'Số điện thoại này đã tồn tại trong danh sách địa chỉ đã lưu';
      }

      final address = AddressModel(
        userId: userId,
        fullName: _fullNameController.text.trim(),
        phone: phoneNumber,
        address: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        isDefault: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _addressService.addAddress(address);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu địa chỉ thành công'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        // Clear form
        _fullNameController.clear();
        _phoneController.clear();
        _addressController.clear();
        _notesController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl2),
        border: Border.all(color: AppColors.adminBorder),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              icon: Icons.local_shipping_outlined,
              title: 'Thông tin giao hàng',
              subtitle: 'Điền thông tin nhận hàng',
            ),
            AppSpacing.gapLg,
            const AdminFieldLabel(label: 'Họ và tên', required: true),
            TextFormField(
              controller: _fullNameController,
              decoration: adminInputDecoration(hintText: 'Nguyễn Văn A'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập họ và tên';
                }
                return null;
              },
            ),
            AppSpacing.gapMd,
            const AdminFieldLabel(label: 'Số điện thoại', required: true),
            TextFormField(
              controller: _phoneController,
              decoration: adminInputDecoration(hintText: '0901234567'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value.trim())) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
            ),
            AppSpacing.gapMd,
            const AdminFieldLabel(label: 'Địa chỉ giao hàng', required: true),
            TextFormField(
              controller: _addressController,
              decoration: adminInputDecoration(
                hintText: 'Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập địa chỉ giao hàng';
                }
                return null;
              },
            ),
            AppSpacing.gapMd,
            const AdminFieldLabel(label: 'Ghi chú'),
            TextFormField(
              controller: _notesController,
              decoration: adminInputDecoration(
                hintText: 'Ghi chú cho đơn hàng (không bắt buộc)',
              ),
              maxLines: 3,
            ),
            AppSpacing.gapLg,
            // Nút lưu địa chỉ mới (outline secondary)
            _SecondaryActionButton(
              icon: _isSaving ? null : Icons.bookmark_add_outlined,
              label: _isSaving ? 'Đang lưu…' : 'Lưu địa chỉ mới',
              loading: _isSaving,
              onPressed: _isSaving ? null : _handleSaveAddress,
            ),
            AppSpacing.gapMd,
            // Nút tiếp tục (primary cam, full-width)
            _PrimaryActionButton(
              icon: Icons.arrow_forward_rounded,
              label: 'Tiếp tục',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final notes = _notesController.text.trim().isEmpty
                      ? null
                      : _notesController.text.trim();
                  widget.onNext(
                    _fullNameController.text.trim(),
                    _phoneController.text.trim(),
                    _addressController.text.trim(),
                    notes,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets nội bộ
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary50,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary600),
        ),
        AppSpacing.gapMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  State<_PrimaryActionButton> createState() => _PrimaryActionButtonState();
}

class _PrimaryActionButtonState extends State<_PrimaryActionButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = _hover ? AppColors.primary600 : AppColors.primary500;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (v) => setState(() => _hover = v),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: disabled ? AppColors.neutral200 : AppColors.adminBorder,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (loading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary500,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, size: 16, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
