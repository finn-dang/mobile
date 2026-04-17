import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/category_model.dart';

class CategoriesDataSource extends DataTableSource {
  final List<CategoryModel> categories;
  final BuildContext context;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;

  CategoriesDataSource({
    required this.categories,
    required this.context,
    required this.onEdit,
    required this.onDelete,
  });

  // Helper method to get parent category name
  String? _getParentName(String? parentId) {
    if (parentId == null) return null;
    final parent = categories.firstWhere(
      (cat) => cat.id == parentId,
      orElse: () => CategoryModel(
        id: '',
        name: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return parent.name;
  }

  @override
  DataRow? getRow(int index) {
    if (index >= categories.length) return null;

    final category = categories[index];
    final isVisible = category.status == 'Hiển thị';
    final parentId = category.parentId;
    final isChild = parentId != null;
    final parentName = _getParentName(parentId);

    return DataRow2(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: category.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedNetworkImage(
                      imageUrl: category.imageUrl!,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.image,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  )
                : Icon(
                    Icons.image,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
          ),
        ),
        DataCell(
          Row(
            children: [
              if (isChild) ...[
                const SizedBox(width: 20),
                Icon(
                  Icons.subdirectory_arrow_right,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isChild ? 14 : 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        DataCell(
          parentName != null
              ? Text(
                  parentName,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                )
              : Text(
                  '—',
                  style: TextStyle(
                    color: Colors.grey[400],
                  ),
                ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVisible ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              category.status,
              style: TextStyle(
                color: isVisible ? Colors.green[700] : Colors.orange[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        DataCell(Text(category.createdAt.toString().split(' ')[0])),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                color: Colors.orange,
                onPressed: () => onEdit(category),
                tooltip: 'Chỉnh sửa',
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 18),
                color: Colors.red,
                onPressed: () => onDelete(category),
                tooltip: 'Xóa',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => categories.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
