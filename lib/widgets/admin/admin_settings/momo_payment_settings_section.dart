import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/payment_settings_model.dart';
import '../../../services/image_service.dart';
import '../../../services/payment_settings_service.dart';
import '../common/admin_card.dart';
import '../common/admin_page_header.dart';

class MomoPaymentSettingsSection extends StatefulWidget {
  const MomoPaymentSettingsSection({super.key});

  @override
  State<MomoPaymentSettingsSection> createState() => _MomoPaymentSettingsSectionState();
}

class _MomoPaymentSettingsSectionState extends State<MomoPaymentSettingsSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _paymentSettingsService = PaymentSettingsService();
  final _imageService = ImageService();

  bool _isMomoEnabled = true;
  bool _isSaving = false;
  bool _initialized = false;
  String? _qrImageUrl;
  PlatformFile? _selectedImage;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _applySettings(PaymentSettingsModel settings) {
    if (_initialized) return;
    _nameController.text = settings.momoName;
    _phoneController.text = settings.momoPhone;
    _qrImageUrl = settings.momoQrImageUrl;
    _isMomoEnabled = settings.isMomoEnabled;
    _initialized = true;
  }

  Future<void> _pickQrImage() async {
    try {
      final file = await _imageService.pickImage();
      if (file == null) return;
      if (!mounted) return;
      setState(() {
        _selectedImage = file;
      });
    } catch (e) {
      _showSnack('Lỗi chọn ảnh: $e', AppColors.error);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      String? finalQrUrl = _qrImageUrl;
      if (_selectedImage != null) {
        finalQrUrl = await _imageService.uploadImage(
          platformFile: _selectedImage!,
          folder: 'payment/momo',
        );
      }

      final settings = PaymentSettingsModel(
        momoName: _nameController.text.trim(),
        momoPhone: _phoneController.text.trim(),
        momoQrImageUrl: finalQrUrl,
        isMomoEnabled: _isMomoEnabled,
        updatedAt: DateTime.now(),
      );

      await _paymentSettingsService.saveSettings(settings);
      if (!mounted) return;
      setState(() {
        _qrImageUrl = finalQrUrl;
        _selectedImage = null;
      });
      _showSnack('Đã lưu cấu hình MoMo', AppColors.success);
    } catch (e) {
      _showSnack('Lỗi lưu cấu hình: $e', AppColors.error);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  Widget _buildQrPreview() {
    if (_selectedImage != null) {
      if (kIsWeb && _selectedImage!.bytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.memory(_selectedImage!.bytes!, fit: BoxFit.cover),
        );
      }
      return const Center(child: Icon(Icons.image_outlined, size: 24));
    }

    if (_qrImageUrl != null && _qrImageUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Image.network(
          _qrImageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Center(child: Icon(Icons.broken_image_outlined)),
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.qr_code_2_rounded, size: 32, color: Colors.grey[500]),
        const SizedBox(height: 6),
        Text(
          'Chưa có ảnh QR',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: StreamBuilder<PaymentSettingsModel>(
        stream: _paymentSettingsService.watchSettings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !_initialized) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.xl2),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            _applySettings(snapshot.data!);
          } else if (!_initialized) {
            _applySettings(PaymentSettingsModel.defaults());
          }

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminSectionTitle(
                  title: 'Cấu hình thanh toán MoMo',
                  description:
                      'Thiết lập tên, số điện thoại và QR MoMo hiển thị cho khách khi chọn thanh toán MoMo.',
                  icon: Icons.qr_code_scanner_rounded,
                  trailing: AdminPrimaryButton(
                    onPressed: _isSaving ? () {} : _save,
                    icon: Icons.save_outlined,
                    label: _isSaving ? 'Đang lưu...' : 'Lưu cấu hình',
                  ),
                ),
                if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: AdminInlineNotice.danger(
                      'Không tải được cấu hình thanh toán: ${snapshot.error}',
                    ),
                  ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _isMomoEnabled,
                  activeColor: AppColors.primary500,
                  title: const Text(
                    'Bật phương thức MoMo',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Tắt để ẩn MoMo khỏi bước chọn thanh toán.',
                  ),
                  onChanged: _isSaving
                      ? null
                      : (v) {
                          setState(() => _isMomoEnabled = v);
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _nameController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Tên tài khoản MoMo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!_isMomoEnabled) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên tài khoản MoMo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phoneController,
                  enabled: !_isSaving,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại MoMo *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (!_isMomoEnabled) return null;
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập số điện thoại MoMo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSaving ? null : _pickQrImage,
                        icon: const Icon(Icons.cloud_upload_outlined),
                        label: const Text('Tải ảnh QR MoMo'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (_selectedImage != null)
                      OutlinedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () => setState(() => _selectedImage = null),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Bỏ ảnh mới'),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.adminBorder),
                  ),
                  child: _buildQrPreview(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
