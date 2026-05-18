import 'package:cached_network_image/cached_network_image.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';
import '../common/admin_card.dart';

/// Cấu trúc nhóm danh mục cha + con cho expandable list.
class ExpandableCategoryRow {
  final CategoryModel category;
  final List<CategoryModel> children;
  bool isExpanded;

  ExpandableCategoryRow({
    required this.category,
    required this.children,
    this.isExpanded = false,
  });
}

// ---------------------------------------------------------------------------
// Parent row
// ---------------------------------------------------------------------------

class ExpandableCategoryDataRow extends DataRow2 {
  final ExpandableCategoryRow expandableRow;
  final BuildContext context;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;
  final VoidCallback? onToggleExpand;

  ExpandableCategoryDataRow({
    required this.expandableRow,
    required this.context,
    required this.onEdit,
    required this.onDelete,
    this.onToggleExpand,
  }) : super(
          onTap: expandableRow.children.isEmpty ? null : onToggleExpand,
          color: WidgetStateProperty.resolveWith(
            (states) => expandableRow.isExpanded
                ? AppColors.primary50.withValues(alpha: 0.5)
                : null,
          ),
          cells: _buildCells(
            expandableRow,
            onEdit,
            onDelete,
            onToggleExpand,
          ),
        );

  static List<DataCell> _buildCells(
    ExpandableCategoryRow row,
    Function(CategoryModel) onEdit,
    Function(CategoryModel) onDelete,
    VoidCallback? onToggleExpand,
  ) {
    final category = row.category;
    final isVisible = category.status == 'Hiển thị';
    final hasChildren = row.children.isNotEmpty;

    return [
      // Image (compact thumb)
      DataCell(_CategoryThumb(imageUrl: category.imageUrl, isParent: true)),

      // Name + chevron expand
      DataCell(
        Row(
          children: [
            _ExpandChevron(
              isExpanded: row.isExpanded,
              hasChildren: hasChildren,
              onPressed: onToggleExpand,
              childCount: row.children.length,
            ),
            AppSpacing.gapSm,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                  if (category.description != null &&
                      category.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      category.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),

      // Parent column – luôn rỗng cho parent row
      const DataCell(
        Text(
          '—',
          style: TextStyle(color: AppColors.neutral400, fontSize: 13),
        ),
      ),

      // Status pill
      DataCell(
        isVisible
            ? AdminStatusPill.success('Hiển thị',
                icon: Icons.visibility_outlined)
            : AdminStatusPill.warning('Đang ẩn',
                icon: Icons.visibility_off_outlined),
      ),

      // Created date
      DataCell(
        Text(
          _formatDate(category.createdAt),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ),

      // Actions
      DataCell(
        _RowActions(
          onEdit: () => onEdit(category),
          onDelete: () => onDelete(category),
        ),
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Child row (nested under parent)
// ---------------------------------------------------------------------------

class ChildCategoryDataRow extends DataRow2 {
  final CategoryModel category;
  final String parentName;
  final BuildContext context;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;

  ChildCategoryDataRow({
    required this.category,
    required this.parentName,
    required this.context,
    required this.onEdit,
    required this.onDelete,
  }) : super(
          color: WidgetStateProperty.all(AppColors.neutral50),
          cells: _buildCells(category, parentName, onEdit, onDelete),
        );

  static List<DataCell> _buildCells(
    CategoryModel category,
    String parentName,
    Function(CategoryModel) onEdit,
    Function(CategoryModel) onDelete,
  ) {
    final isVisible = category.status == 'Hiển thị';

    return [
      DataCell(_CategoryThumb(imageUrl: category.imageUrl, isParent: false)),
      DataCell(
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Row(
            children: [
              // Tree connector
              const Icon(
                Icons.subdirectory_arrow_right,
                size: 14,
                color: AppColors.neutral400,
              ),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (category.description != null &&
                        category.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        category.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      DataCell(AdminStatusPill.neutral(parentName, icon: Icons.folder_outlined)),
      DataCell(
        isVisible
            ? AdminStatusPill.success('Hiển thị',
                icon: Icons.visibility_outlined)
            : AdminStatusPill.warning('Đang ẩn',
                icon: Icons.visibility_off_outlined),
      ),
      DataCell(
        Text(
          _formatDate(category.createdAt),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      DataCell(
        _RowActions(
          onEdit: () => onEdit(category),
          onDelete: () => onDelete(category),
        ),
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _CategoryThumb extends StatelessWidget {
  final String? imageUrl;
  final bool isParent;
  const _CategoryThumb({required this.imageUrl, required this.isParent});

  @override
  Widget build(BuildContext context) {
    final size = isParent ? 36.0 : 32.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.4,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => const Icon(
                  Icons.category_outlined,
                  size: 16,
                  color: AppColors.neutral400,
                ),
              )
            : const Icon(
                Icons.category_outlined,
                size: 16,
                color: AppColors.neutral400,
              ),
      ),
    );
  }
}

class _ExpandChevron extends StatelessWidget {
  final bool isExpanded;
  final bool hasChildren;
  final VoidCallback? onPressed;
  final int childCount;

  const _ExpandChevron({
    required this.isExpanded,
    required this.hasChildren,
    required this.onPressed,
    required this.childCount,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasChildren) {
      return const SizedBox(width: 22);
    }
    return Tooltip(
      message: isExpanded ? 'Thu gọn' : 'Mở rộng ($childCount danh mục con)',
      child: SizedBox(
        width: 22,
        height: 22,
        child: Material(
          color: isExpanded ? AppColors.primary50 : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 180),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isExpanded
                    ? AppColors.primary600
                    : AppColors.neutral500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RowActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _RowActions({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconAction(
          icon: Icons.edit_outlined,
          tooltip: 'Chỉnh sửa',
          color: AppColors.primary600,
          onPressed: onEdit,
        ),
        AppSpacing.gapXs,
        _IconAction(
          icon: Icons.delete_outline_rounded,
          tooltip: 'Xóa',
          color: AppColors.error,
          onPressed: onDelete,
        ),
      ],
    );
  }
}

class _IconAction extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onPressed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_IconAction> createState() => _IconActionState();
}

class _IconActionState extends State<_IconAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Material(
          color: _hover
              ? widget.color.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: InkWell(
            onTap: widget.onPressed,
            onHover: (v) => setState(() => _hover = v),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
