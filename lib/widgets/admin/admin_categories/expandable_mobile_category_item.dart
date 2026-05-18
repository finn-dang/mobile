import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/category_model.dart';

class ExpandableMobileCategoryItem extends StatelessWidget {
  final CategoryModel category;
  final List<CategoryModel> children;
  final bool isExpanded;
  final VoidCallback onToggle;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;

  const ExpandableMobileCategoryItem({
    super.key,
    required this.category,
    required this.children,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isVisible = category.status == 'Hiển thị';
    final hasChildren = children.isNotEmpty;

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
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
            title: Row(
              children: [
                if (hasChildren)
                  InkWell(
                    onTap: onToggle,
                    child: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  )
                else
                  const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.description ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${category.productCount} sản phẩm',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isVisible
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.status,
                        style: TextStyle(
                          color: isVisible ? Colors.green[700] : Colors.orange[700],
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Sửa'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit(category);
                } else if (value == 'delete') {
                  onDelete(category);
                }
              },
            ),
          ),
        ),
        // Show children when expanded
        if (isExpanded && hasChildren)
          ...children.map((child) {
            final childIsVisible = child.status == 'Hiển thị';
            return Card(
              margin: const EdgeInsets.only(left: 32, bottom: 8, right: 0),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: child.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: CachedNetworkImage(
                            imageUrl: child.imageUrl!,
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
                title: Row(
                  children: [
                    Icon(
                      Icons.subdirectory_arrow_right,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        child.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.description ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${child.productCount} sản phẩm',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: childIsVisible
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            child.status,
                            style: TextStyle(
                              color: childIsVisible ? Colors.green[700] : Colors.orange[700],
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit(child);
                    } else if (value == 'delete') {
                      onDelete(child);
                    }
                  },
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}

