import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../models/home_section_model.dart';
import 'product_selection_dialog.dart';

class EditSectionDialog extends StatefulWidget {
  final HomeSectionModel section;

  const EditSectionDialog({
    super.key,
    required this.section,
  });

  @override
  State<EditSectionDialog> createState() => _EditSectionDialogState();
}

class _EditSectionDialogState extends State<EditSectionDialog> {
  late final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _orderController;
  late List<String> _selectedProductIds;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.section.title);
    _orderController =
        TextEditingController(text: widget.section.order.toString());
    _selectedProductIds = List.from(widget.section.productIds);
    _startDate = widget.section.startDate;
    _endDate = widget.section.endDate;
    _isActive = widget.section.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _selectProducts() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => ProductSelectionDialog(
        selectedProductIds: _selectedProductIds,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedProductIds = result;
      });
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

  void _handleUpdate() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một sản phẩm'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final order = int.tryParse(_orderController.text) ?? 0;

    final section = widget.section.copyWith(
      title: _titleController.text,
      productIds: _selectedProductIds,
      startDate: _startDate,
      endDate: _endDate,
      order: order,
      isActive: _isActive,
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pop(section);
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
              title: const Text('Sửa bộ sưu tập trang chủ'),
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
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          return null;
                        },
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
                      OutlinedButton.icon(
                        onPressed: _selectProducts,
                        icon: const Icon(Icons.shopping_bag),
                        label: Text(
                          _selectedProductIds.isEmpty
                              ? 'Chọn sản phẩm *'
                              : 'Đã chọn ${_selectedProductIds.length} sản phẩm',
                        ),
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
                        title: const Text('Đang hiển thị'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value ?? true;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _handleUpdate,
                        child: const Text('Cập nhật'),
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

