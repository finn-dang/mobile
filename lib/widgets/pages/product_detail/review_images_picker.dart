import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReviewImagesPicker extends StatelessWidget {
  final List<PlatformFile> selectedImages;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final bool isSubmitting;

  const ReviewImagesPicker({
    super.key,
    required this.selectedImages,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.isSubmitting,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hình ảnh (tùy chọn)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        if (selectedImages.isEmpty)
          OutlinedButton.icon(
            onPressed: isSubmitting ? null : onPickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Thêm hình ảnh'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final image = entry.value;
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? image.bytes != null
                                ? Image.memory(
                                    image.bytes!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image, size: 40)
                            : image.path != null
                                ? Image.file(
                                    File(image.path!),
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.image, size: 40),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () => onRemoveImage(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                );
              }),
              if (selectedImages.length < 10)
                GestureDetector(
                  onTap: isSubmitting ? null : onPickImages,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[300]!,
                      ),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
        if (selectedImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Đã chọn ${selectedImages.length} hình ảnh (tối đa 10)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }
}

