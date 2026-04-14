import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/home_section_model.dart';
import '../common/admin_card.dart';

class SectionsDataSource extends DataTableSource {
  final List<HomeSectionModel> sections;
  final Function(HomeSectionModel) onEdit;
  final Function(HomeSectionModel) onDelete;

  SectionsDataSource({
    required this.sections,
    required this.onEdit,
    required this.onDelete,
  });

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  DataRow? getRow(int index) {
    if (index >= sections.length) return null;
    final section = sections[index];

    String timeRange = 'Luôn hiển thị';
    if (section.startDate != null || section.endDate != null) {
      final start =
          section.startDate != null ? _formatDate(section.startDate!) : '';
      final end =
          section.endDate != null ? _formatDate(section.endDate!) : '';
      if (start.isNotEmpty && end.isNotEmpty) {
        timeRange = '$start  →  $end';
      } else if (start.isNotEmpty) {
        timeRange = 'Từ $start';
      } else if (end.isNotEmpty) {
        timeRange = 'Đến $end';
      }
    }

    return DataRow2(
      cells: [
        DataCell(
          Text(
            section.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              color: AppColors.textPrimary,
              letterSpacing: -0.1,
            ),
          ),
        ),
        DataCell(
          AdminStatusPill.info(
            '${section.productIds.length} SP',
            icon: Icons.inventory_2_outlined,
          ),
        ),
        DataCell(
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.adminBorder),
            ),
            child: Text(
              '${section.order}',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        DataCell(
          section.isActive
              ? AdminStatusPill.success(
                  'Đang hiển thị',
                  icon: Icons.check_circle_outline_rounded,
                )
              : AdminStatusPill.warning(
                  'Tạm tắt',
                  icon: Icons.toggle_off_outlined,
                ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: AppColors.neutral400,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  timeRange,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconAction(
                icon: Icons.edit_outlined,
                tooltip: 'Sửa',
                color: AppColors.primary600,
                onPressed: () => onEdit(section),
              ),
              AppSpacing.gapXs,
              _IconAction(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Xoá',
                color: AppColors.error,
                onPressed: () => onDelete(section),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => sections.length;

  @override
  int get selectedRowCount => 0;
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
