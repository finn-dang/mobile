import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'product_text_field.dart';

class ImageAndDescriptionSection extends StatelessWidget {
  final PlatformFile? selectedImageFile;
  final String? imageUrl;
  final VoidCallback onPickImage;
  final TextEditingController descriptionController;
  final bool isUploading;
  final bool isTablet;

  const ImageAndDescriptionSection({
    super.key,
    required this.selectedImageFile,
    required this.imageUrl,
    required this.onPickImage,
    required this.descriptionController,
    required this.isUploading,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hình ảnh & Mô tả',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 20,
                  ),
            ),
            const SizedBox(height: 24),
            // Image picker button
            ElevatedButton.icon(
              onPressed: isUploading ? null : onPickImage,
              icon: const Icon(Icons.image),
              label: const Text('Chọn hình ảnh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            // Image preview
            Builder(
              builder: (context) {
                if (selectedImageFile != null) {
                  // Show selected file preview
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.memory(
                              selectedImageFile!.bytes!,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(selectedImageFile!.path!),
                              fit: BoxFit.cover,
                            ),
                    ),
                  );
                } else if (imageUrl != null && imageUrl!.isNotEmpty) {
                  // Show existing image from URL
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(Icons.image, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (isUploading) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Đang tải ảnh lên...',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ProductTextField(
              controller: descriptionController,
              label: 'Mô tả sản phẩm',
              hint: 'Nhập mô tả sản phẩm...',
              maxLines: 8,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }
}

