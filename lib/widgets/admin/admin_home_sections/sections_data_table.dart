import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/home_section_model.dart';
import 'sections_data_source.dart';

class SectionsDataTable extends StatelessWidget {
  final List<HomeSectionModel> sections;
  final Function(HomeSectionModel) onEdit;
  final Function(HomeSectionModel) onDelete;

  const SectionsDataTable({
    super.key,
    required this.sections,
    required this.onEdit,
    required this.onDelete,
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
    bool numeric = false,
  }) =>
      DataColumn2(
        label: Text(label.toUpperCase(), style: _headerStyle),
        size: size,
        numeric: numeric,
      );

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable2(
      minWidth: 1000,
      columnSpacing: 16,
      horizontalMargin: 16,
      rowsPerPage: 10,
      headingRowColor: WidgetStateProperty.all(AppColors.neutral50),
      headingRowHeight: 44,
      dataRowHeight: 60,
      dividerThickness: 0.6,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.neutral100,
          width: 1,
        ),
      ),
      columns: [
        _column('Tiêu đề', size: ColumnSize.L),
        _column('Sản phẩm', size: ColumnSize.S),
        _column('Thứ tự', size: ColumnSize.S),
        _column('Trạng thái', size: ColumnSize.M),
        _column('Thời gian hiển thị', size: ColumnSize.L),
        _column('Hành động', size: ColumnSize.S),
      ],
      source: SectionsDataSource(
        sections: sections,
        onEdit: onEdit,
        onDelete: onDelete,
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
                Icons.view_list_outlined,
                size: 26,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Chưa có bộ sưu tập nào',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tạo bộ sưu tập mới để hiển thị nhóm sản phẩm trên trang chủ.',
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
