import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../common/admin_card.dart';
import '../common/admin_page_header.dart';

/// Khu vực quản lý hình ảnh sản phẩm – Modern Minimal.
///
/// • Empty state: dropzone với border dashed.
/// • Image item: bo nhẹ, badge "Ảnh chính" pill primary, nút xóa hover hiện.
class ProductImagesSection extends StatelessWidget {
  final List<PlatformFile> selectedImageFiles;
  final List<String> imageUrls;
  final VoidCallback onPickImages;
  final Function(int) onRemoveImage;
  final bool isUploading;
  final bool isTablet;

  const ProductImagesSection({
    super.key,
    required this.selectedImageFiles,
    required this.imageUrls,
    required this.onPickImages,
    required this.onRemoveImage,
    required this.isUploading,
    required this.isTablet,
  });

  int get _totalImages => selectedImageFiles.length + imageUrls.length;

  @override
  Widget build(BuildContext context) {
    final tileSize = isTablet ? 110.0 : 128.0;

    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionTitle(
            title: 'Hình ảnh sản phẩm',
            description: _totalImages == 0
                ? 'Chưa có ảnh – tải lên ảnh đầu tiên để bắt đầu.'
                : 'Ảnh đầu tiên là ảnh chính. Có thể kéo thả lại sau.',
            trailing: AdminSecondaryButton(
              icon: Icons.add_photo_alternate_outlined,
              label: 'Tải ảnh',
              onPressed: isUploading ? () {} : onPickImages,
            ),
          ),
          if (isUploading)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.md),
              child: AdminInlineNotice(
                message: 'Đang tải ảnh lên, vui lòng đợi...',
                icon: Icons.cloud_upload_outlined,
                fg: AppColors.infoDark,
                bg: AppColors.infoContainer,
                border: AppColors.infoLight,
              ),
            ),
          if (_totalImages == 0)
            _DropzoneEmptyState(onTap: isUploading ? null : onPickImages)
          else
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                for (var i = 0; i < selectedImageFiles.length; i++)
                  _ImageTile(
                    size: tileSize,
                    isMain: i == 0,
                    isFile: true,
                    file: selectedImageFiles[i],
                    onRemove: () => onRemoveImage(i),
                  ),
                for (var i = 0; i < imageUrls.length; i++)
                  _ImageTile(
                    size: tileSize,
                    isMain: selectedImageFiles.isEmpty && i == 0,
                    isFile: false,
                    url: imageUrls[i],
                    onRemove: () =>
                        onRemoveImage(selectedImageFiles.length + i),
                  ),
                _AddMoreTile(
                  size: tileSize,
                  onTap: isUploading ? null : onPickImages,
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _DropzoneEmptyState extends StatelessWidget {
  final VoidCallback? onTap;
  const _DropzoneEmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: DottedBorderBox(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl3),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(AppRadius.xl2),
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 22,
                  color: AppColors.primary600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Tải lên ảnh sản phẩm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'PNG, JPG, WebP – tối đa 5MB mỗi ảnh',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Container giả border dashed (Flutter chưa hỗ trợ DashPath border native
/// thuần CSS, nên ta vẽ bằng CustomPaint).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.primary300,
        radius: AppRadius.lg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary50.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rect);

    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dash;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

class _ImageTile extends StatefulWidget {
  final double size;
  final bool isMain;
  final bool isFile;
  final PlatformFile? file;
  final String? url;
  final VoidCallback onRemove;

  const _ImageTile({
    required this.size,
    required this.isMain,
    required this.isFile,
    required this.onRemove,
    this.file,
    this.url,
  });

  @override
  State<_ImageTile> createState() => _ImageTileState();
}

class _ImageTileState extends State<_ImageTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Container(
                color: AppColors.neutral100,
                child: widget.isFile
                    ? _renderFile(widget.file!)
                    : _renderUrl(widget.url!),
              ),
            ),
            // Outline border
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.adminBorder,
                    width: 1,
                  ),
                ),
              ),
            ),
            // Main badge
            if (widget.isMain)
              Positioned(
                top: 6,
                left: 6,
                child: AdminStatusPill(
                  label: 'Ảnh chính',
                  fg: Colors.white,
                  bg: AppColors.primary500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                ),
              ),
            // Remove button (always visible on touch, hover-revealed on desktop)
            Positioned(
              top: 6,
              right: 6,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: _hover ? 1 : 0.85,
                child: Material(
                  color: AppColors.neutral900.withValues(alpha: 0.65),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: widget.onRemove,
                    customBorder: const CircleBorder(),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderFile(PlatformFile file) {
    if (kIsWeb) {
      if (file.bytes == null) return const _ImageError();
      return Image.memory(file.bytes!, fit: BoxFit.cover);
    }
    if (file.path == null) return const _ImageError();
    return Image.file(File(file.path!), fit: BoxFit.cover);
  }

  Widget _renderUrl(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 1.6,
            color: AppColors.primary500,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => const _ImageError(),
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.broken_image_outlined,
        size: 22,
        color: AppColors.neutral400,
      ),
    );
  }
}

class _AddMoreTile extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  const _AddMoreTile({required this.size, this.onTap});

  @override
  State<_AddMoreTile> createState() => _AddMoreTileState();
}

class _AddMoreTileState extends State<_AddMoreTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _hover && !disabled
                ? AppColors.primary50
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color:
                  _hover && !disabled ? AppColors.primary300 : AppColors.adminBorder,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: AppColors.neutral500,
                ),
                SizedBox(height: 4),
                Text(
                  'Thêm ảnh',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w500,
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
