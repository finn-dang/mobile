import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../models/category_model.dart';
import '../../web_safe_network_image.dart';

class ChildCategoriesList extends StatelessWidget {
  final List<CategoryModel> childCategories;
  final String? selectedChildId;
  final Function(String?) onChildSelected;

  const ChildCategoriesList({
    super.key,
    required this.childCategories,
    required this.selectedChildId,
    required this.onChildSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (childCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục con',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isMobile ? 100 : 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: childCategories.length,
              itemBuilder: (context, index) {
                final category = childCategories[index];
                final isSelected = selectedChildId == category.id;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < childCategories.length - 1 ? 12 : 0,
                  ),
                  child: InkWell(
                    onTap: () => onChildSelected(isSelected ? null : category.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: isMobile ? 100 : 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          category.imageUrl != null
                              ? ClipOval(
                                  child: WebSafeNetworkImage(
                                    imageUrl: category.imageUrl!,
                                    width: isMobile ? 40 : 48,
                                    height: isMobile ? 40 : 48,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => SizedBox(
                                      width: isMobile ? 40 : 48,
                                      height: isMobile ? 40 : 48,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          isSelected
                                              ? Colors.white
                                              : Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.category,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.primary,
                                      size: isMobile ? 40 : 48,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.category,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  size: isMobile ? 40 : 48,
                                ),
                          const SizedBox(height: 8),
                          Flexible(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: isMobile ? 12 : 14,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

