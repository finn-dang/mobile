import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/review_model.dart';
import '../common/admin_card.dart';
import 'review_detail_dialog.dart';

class ReviewsDataTable extends StatelessWidget {
  final List<ReviewModel> reviews;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final int rowsPerPage;
  final ValueChanged<int?>? onRowsPerPageChanged;
  final bool isTablet;
  final String Function(DateTime) formatDate;

  const ReviewsDataTable({
    super.key,
    required this.reviews,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.rowsPerPage,
    this.onRowsPerPageChanged,
    required this.isTablet,
    required this.formatDate,
  });

  static const TextStyle _headerStyle = TextStyle(
    color: AppColors.neutral600,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 0.3,
  );

  DataColumn2 _column(
    String label, {
    ColumnSize size = ColumnSize.M,
    int? sortIndex,
  }) =>
      DataColumn2(
        label: Text(label.toUpperCase(), style: _headerStyle),
        size: size,
        onSort: sortIndex == null
            ? null
            : (_, ascending) => onSort(sortIndex, ascending),
      );

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: isTablet ? 800 : 1100,
      columnSpacing: isTablet ? 8 : 16,
      horizontalMargin: isTablet ? 8 : 16,
      rowsPerPage: rowsPerPage,
      onRowsPerPageChanged: onRowsPerPageChanged,
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
      headingRowHeight: 44,
      dataRowHeight: 64,
      dividerThickness: 0.6,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.neutral100,
          width: 1,
        ),
      ),
      columns: [
        _column('Người dùng', size: ColumnSize.M, sortIndex: 0),
        _column('Mã sản phẩm', size: ColumnSize.M, sortIndex: 1),
        _column('Đánh giá', size: ColumnSize.S, sortIndex: 2),
        _column('Nội dung', size: ColumnSize.L),
        _column('Ảnh', size: ColumnSize.S),
        _column('Phản hồi', size: ColumnSize.S, sortIndex: 3),
        _column('Ngày', size: ColumnSize.M, sortIndex: 4),
        _column('Hành động', size: ColumnSize.S),
      ],
      source: ReviewsDataSource(
        reviews: reviews,
        context: context,
        onView: (review) {
          showDialog(
            context: context,
            builder: (_) => ReviewDetailDialog(review: review),
          );
        },
        formatDate: formatDate,
      ),
      empty: const _EmptyState(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(AppRadius.xl2),
              ),
              child: const Icon(
                Icons.reviews_outlined,
                size: 26,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Không có đánh giá nào',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Thử điều chỉnh bộ lọc hoặc kiểm tra lại sau.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewsDataSource extends DataTableSource {
  final List<ReviewModel> reviews;
  final BuildContext context;
  final Function(ReviewModel) onView;
  final String Function(DateTime) formatDate;

  ReviewsDataSource({
    required this.reviews,
    required this.context,
    required this.onView,
    required this.formatDate,
  });

  @override
  DataRow? getRow(int index) {
    if (index >= reviews.length) return null;
    final review = reviews[index];

    return DataRow2(
      cells: [
        // User
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _UserAvatar(name: review.userName),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  review.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Product ID
        DataCell(
          Text(
            review.productId,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // Rating stars
        DataCell(_RatingStars(rating: review.rating)),
        // Comment
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              review.comment,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ),
        // Images count
        DataCell(
          review.imageUrls.isEmpty
              ? const Text(
                  '—',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 13,
                  ),
                )
              : AdminStatusPill.info(
                  '${review.imageUrls.length}',
                  icon: Icons.image_outlined,
                ),
        ),
        // Reply status
        DataCell(
          review.adminReply != null
              ? AdminStatusPill.success(
                  'Đã phản hồi',
                  icon: Icons.check_circle_outline_rounded,
                )
              : AdminStatusPill.warning(
                  'Chưa phản hồi',
                  icon: Icons.pending_actions_outlined,
                ),
        ),
        // Date
        DataCell(
          Text(
            formatDate(review.createdAt),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // Action
        DataCell(
          _IconAction(
            icon: Icons.visibility_outlined,
            tooltip: 'Xem chi tiết',
            color: AppColors.info,
            onPressed: () => onView(review),
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => reviews.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _UserAvatar extends StatelessWidget {
  final String name;
  const _UserAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: AppColors.primary600,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final int rating;
  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 14,
            color: i < rating ? AppColors.warning : AppColors.neutral300,
          ),
        const SizedBox(width: 4),
        Text(
          '$rating',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
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
