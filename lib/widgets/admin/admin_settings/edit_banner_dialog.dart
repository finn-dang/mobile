import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/banner_model.dart';
import '../../../services/image_service.dart';

class EditBannerDialog extends StatefulWidget {
  final BannerModel banner;

  const EditBannerDialog({
    super.key,
    required this.banner,
  });

  @override
  State<EditBannerDialog> createState() => _EditBannerDialogState();
}

class _EditBannerDialogState extends State<EditBannerDialog> {
  late final _formKey = GlobalKey<FormState>();
  late final TextEditingController _linkController;
  late final TextEditingController _orderController;
  late String _imageUrl;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late bool _isActive;
  final _imageService = ImageService();
  PlatformFile? _selectedImageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _linkController = TextEditingController(text: widget.banner.link ?? '');
    _orderController = TextEditingController(text: widget.banner.order.toString());
    _imageUrl = widget.banner.imageUrl;
    _startDate = widget.banner.startDate;
    _endDate = widget.banner.endDate;
    _isActive = widget.banner.isActive;
  }

  @override
  void dispose() {
    _linkController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final platformFile = await _imageService.pickImage();
      if (platformFile != null) {
        setState(() {
          _selectedImageFile = platformFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? (_startDate ?? DateTime.now()),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isUploading = true;
    });

    try {
      String finalImageUrl = _imageUrl;

      if (_selectedImageFile != null) {
        final uploadedUrl = await _imageService.uploadImage(
          platformFile: _selectedImageFile!,
          folder: 'banners',
        );
        finalImageUrl = uploadedUrl;
      }

      final order = int.tryParse(_orderController.text) ?? 0;

      final banner = widget.banner.copyWith(
        imageUrl: finalImageUrl,
        link: _linkController.text.isEmpty ? null : _linkController.text,
        order: order,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        Navigator.of(context).pop(banner);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Dialog(
      child: Container(
        width: isMobile ? double.infinity : 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Sửa Banner'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image picker
                      OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Chọn ảnh banner mới'),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isUploading
                            ? const Center(child: CircularProgressIndicator())
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _selectedImageFile != null
                                    ? Image.memory(
                                        _selectedImageFile!.bytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: _imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _linkController,
                        decoration: const InputDecoration(
                          labelText: 'Link (tùy chọn)',
                          hintText: 'URL khi click vào banner',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orderController,
                        decoration: const InputDecoration(
                          labelText: 'Thứ tự hiển thị *',
                          border: OutlineInputBorder(),
                          helperText: 'Số nhỏ hơn sẽ hiển thị trước',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập thứ tự';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Vui lòng nhập số hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      isMobile
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _selectStartDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _startDate == null
                                          ? 'Ngày bắt đầu (tùy chọn)'
                                          : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _selectEndDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _endDate == null
                                          ? 'Ngày kết thúc (tùy chọn)'
                                          : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _selectStartDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _startDate == null
                                          ? 'Ngày bắt đầu (tùy chọn)'
                                          : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _selectEndDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _endDate == null
                                          ? 'Ngày kết thúc (tùy chọn)'
                                          : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Active'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value ?? true;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isUploading ? null : _handleUpdate,
                        child: _isUploading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Cập nhật'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

