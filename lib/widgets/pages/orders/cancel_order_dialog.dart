import 'package:flutter/material.dart';

class CancelOrderDialog extends StatefulWidget {
  final String orderCode;

  const CancelOrderDialog({
    super.key,
    required this.orderCode,
  });

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String? _selectedReason;
  bool _showCustomReason = false;

  static const List<String> _cancellationReasons = [
    'Đổi ý, không muốn mua nữa',
    'Tìm thấy sản phẩm rẻ hơn ở nơi khác',
    'Thông tin giao hàng sai',
    'Lý do khác',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _onReasonSelected(String? reason) {
    setState(() {
      _selectedReason = reason;
      if (reason == 'Lý do khác') {
        _showCustomReason = true;
        _reasonController.clear();
      } else {
        _showCustomReason = false;
        _reasonController.text = reason ?? '';
      }
    });
  }

  String? _getFinalReason() {
    if (_selectedReason == 'Lý do khác') {
      return _reasonController.text.trim();
    }
    return _selectedReason;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cancel_outlined, color: Colors.red[700], size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Hủy đơn hàng',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Order code
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'Mã đơn hàng: ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      widget.orderCode,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bạn có chắc chắn muốn hủy đơn hàng này?',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Reason selection
              Text(
                'Lý do hủy đơn hàng *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              ..._cancellationReasons.map((reason) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: (value) => _onReasonSelected(value),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: _selectedReason == reason
                            ? Colors.red
                            : Colors.grey[300]!,
                        width: _selectedReason == reason ? 2 : 1,
                      ),
                    ),
                    tileColor: _selectedReason == reason
                        ? Colors.red[50]
                        : Colors.grey[50],
                  ),
                );
              }),
              // Custom reason input (only show when "Lý do khác" is selected)
              if (_showCustomReason) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reasonController,
                  decoration: InputDecoration(
                    labelText: 'Vui lòng nhập lý do hủy đơn hàng *',
                    hintText: 'Nhập lý do hủy đơn hàng của bạn',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.edit_note),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập lý do hủy đơn hàng';
                    }
                    if (value.trim().length < 10) {
                      return 'Lý do hủy đơn hàng phải có ít nhất 10 ký tự';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedReason == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng chọn lý do hủy đơn hàng'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate()) {
                          final finalReason = _getFinalReason();
                          if (finalReason != null && finalReason.isNotEmpty) {
                            Navigator.of(context).pop(finalReason);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Xác nhận hủy'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

