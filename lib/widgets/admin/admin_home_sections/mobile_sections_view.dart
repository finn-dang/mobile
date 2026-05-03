import 'package:flutter/material.dart';
import '../../../models/home_section_model.dart';

class MobileSectionsView extends StatelessWidget {
  final List<HomeSectionModel> sections;
  final Function(HomeSectionModel) onEdit;
  final Function(HomeSectionModel) onDelete;

  const MobileSectionsView({
    super.key,
    required this.sections,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
            child: Text('Không có bộ sưu tập nào'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];

        String timeRangeText = 'Luôn hiển thị';
        if (section.startDate != null || section.endDate != null) {
          final start = section.startDate != null
              ? '${section.startDate!.day}/${section.startDate!.month}/${section.startDate!.year}'
              : '';
          final end = section.endDate != null
              ? '${section.endDate!.day}/${section.endDate!.month}/${section.endDate!.year}'
              : '';
          if (start.isNotEmpty && end.isNotEmpty) {
            timeRangeText = '$start - $end';
          } else if (start.isNotEmpty) {
            timeRangeText = 'Từ $start';
          } else if (end.isNotEmpty) {
            timeRangeText = 'Đến $end';
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.edit, size: 20, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Sửa'),
                            ],
                          ),
                          onTap: () => Future.delayed(
                            const Duration(milliseconds: 100),
                            () => onEdit(section),
                          ),
                        ),
                        PopupMenuItem(
                          child: const Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Xóa'),
                            ],
                          ),
                          onTap: () => Future.delayed(
                            const Duration(milliseconds: 100),
                            () => onDelete(section),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(
                      'Số sản phẩm: ${section.productIds.length}',
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      'Thứ tự: ${section.order}',
                      Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: section.isActive ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    section.isActive ? 'Đang hiển thị' : 'Tạm tắt',
                    style: TextStyle(
                      color: section.isActive ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thời gian: $timeRangeText',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

