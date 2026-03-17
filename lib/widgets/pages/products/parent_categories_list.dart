import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../models/category_model.dart';
import '../../web_safe_network_image.dart';

class ParentCategoriesList extends StatelessWidget {
  final List<CategoryModel> parentCategories;
  final String? selectedParentId;
  final Function(String?) onParentSelected;

  const ParentCategoriesList({
    super.key,
    required this.parentCategories,
    required this.selectedParentId,
    required this.onParentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danh mục',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isMobile ? 80 : 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: parentCategories.length,
              itemBuilder: (context, index) {
                final category = parentCategories[index];
                final isSelected = selectedParentId == category.id;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < parentCategories.length - 1 ? 12 : 0,
                  ),
                  child: InkWell(
                    onTap: () => onParentSelected(isSelected ? null : category.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: isMobile ? 100 : 120,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[100],
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
                                    width: isMobile ? 28 : 32,
                                    height: isMobile ? 28 : 32,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => SizedBox(
                                      width: isMobile ? 28 : 32,
                                      height: isMobile ? 28 : 32,
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
                                      size: isMobile ? 28 : 32,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.category,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).colorScheme.primary,
                                  size: isMobile ? 28 : 32,
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

