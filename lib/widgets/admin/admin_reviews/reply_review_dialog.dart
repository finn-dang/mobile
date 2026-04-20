import 'package:flutter/material.dart';

class ReplyReviewDialog extends StatefulWidget {
  final String reviewId;
  final String? existingReply;

  const ReplyReviewDialog({
    super.key,
    required this.reviewId,
    this.existingReply,
  });

  @override
  State<ReplyReviewDialog> createState() => _ReplyReviewDialogState();
}

class _ReplyReviewDialogState extends State<ReplyReviewDialog> {
  final TextEditingController _replyController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReply != null) {
      _replyController.text = widget.existingReply!;
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _submitReply() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    // Return the reply text
    if (mounted) {
      Navigator.of(context).pop(_replyController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingReply != null ? 'Sửa phản hồi' : 'Phản hồi đánh giá'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: TextFormField(
            controller: _replyController,
            enabled: !_isSubmitting,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Nội dung phản hồi',
              hintText: 'Nhập phản hồi của bạn...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập nội dung phản hồi';
              }
              if (value.trim().length < 10) {
                return 'Phản hồi phải có ít nhất 10 ký tự';
              }
              return null;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReply,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.existingReply != null ? 'Cập nhật' : 'Gửi'),
        ),
      ],
    );
  }
}

