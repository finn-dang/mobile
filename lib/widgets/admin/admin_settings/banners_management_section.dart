import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/banner_model.dart';
import '../../../services/banner_service.dart';
import '../common/admin_card.dart';
import '../common/admin_page_header.dart';
import 'banners_list_view.dart';
import 'create_banner_dialog.dart';
import 'delete_banner_dialog.dart';
import 'edit_banner_dialog.dart';

/// Section "Quản lý Banners" – Modern Minimal.
class BannersManagementSection extends StatefulWidget {
  const BannersManagementSection({super.key});

  @override
  State<BannersManagementSection> createState() =>
      _BannersManagementSectionState();
}

class _BannersManagementSectionState extends State<BannersManagementSection> {
  final _bannerService = BannerService();

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleCreate() async {
    final result = await showDialog<BannerModel>(
      context: context,
      builder: (_) => const CreateBannerDialog(),
    );
    if (result != null && mounted) {
      try {
        await _bannerService.createBanner(result);
        if (!mounted) return;
        _snack('Đã tạo banner thành công', AppColors.success);
      } catch (e) {
        if (!mounted) return;
        _snack('Lỗi: $e', AppColors.error);
      }
    }
  }

  Future<void> _handleEdit(BannerModel banner) async {
    final result = await showDialog<BannerModel>(
      context: context,
      builder: (_) => EditBannerDialog(banner: banner),
    );
    if (result != null && mounted) {
      try {
        await _bannerService.updateBanner(result);
        if (!mounted) return;
        _snack('Đã cập nhật banner', AppColors.success);
      } catch (e) {
        if (!mounted) return;
        _snack('Lỗi: $e', AppColors.error);
      }
    }
  }

  Future<void> _handleDelete(BannerModel banner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteBannerDialog(banner: banner),
    );
    if (confirmed == true && mounted) {
      try {
        await _bannerService.deleteBanner(banner.id);
        if (!mounted) return;
        _snack('Đã xoá banner', AppColors.success);
      } catch (e) {
        if (!mounted) return;
        _snack('Lỗi: $e', AppColors.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AdminSectionTitle(
            title: 'Banners trang chủ',
            description:
                'Hiển thị nổi bật ở phần đầu trang chủ. Khuyến nghị 3-5 banner.',
            icon: Icons.collections_outlined,
            trailing: AdminPrimaryButton(
              icon: Icons.add_rounded,
              label: 'Thêm banner',
              onPressed: _handleCreate,
            ),
          ),
          StreamBuilder<List<BannerModel>>(
            stream: _bannerService.getAllBanners(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.xl3),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return AdminInlineNotice.danger(
                  'Lỗi khi tải banners: ${snapshot.error}',
                );
              }
              final banners = snapshot.data ?? const [];
              if (banners.isEmpty) {
                return const _EmptyBanners();
              }
              return BannersListView(
                banners: banners,
                onEdit: _handleEdit,
                onDelete: _handleDelete,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyBanners extends StatelessWidget {
  const _EmptyBanners();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl3),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary50,
              borderRadius: BorderRadius.circular(AppRadius.xl2),
            ),
            child: const Icon(
              Icons.collections_outlined,
              size: 22,
              color: AppColors.primary600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Chưa có banner nào',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tạo banner đầu tiên để hiển thị nổi bật trên trang chủ.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
