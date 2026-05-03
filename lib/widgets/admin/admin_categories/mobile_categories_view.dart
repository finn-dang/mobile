import 'package:flutter/material.dart';
import 'categories_search_and_filter_bar.dart';
import 'expandable_mobile_category_item.dart';
import 'expandable_category_row.dart';
import '../../../models/category_model.dart';

class MobileCategoriesView extends StatelessWidget {
  final List<ExpandableCategoryRow> expandableRows;
  final TextEditingController searchController;
  final String? selectedStatus;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onClearFilters;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;
  final Function(int, bool) onSort;
  final int sortColumnIndex;
  final bool sortAscending;
  final VoidCallback onCreate;
  final Function(String) onToggleExpand;

  const MobileCategoriesView({
    super.key,
    required this.expandableRows,
    required this.searchController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearFilters,
    required this.onEdit,
    required this.onDelete,
    required this.onSort,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onCreate,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý danh mục',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add),
                label: const Text('Thêm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search and Filter
          CategoriesSearchAndFilterBar(
            searchController: searchController,
            selectedStatus: selectedStatus,
            onStatusChanged: onStatusChanged,
            onClearFilters: onClearFilters,
            isTablet: false,
          ),
          const SizedBox(height: 16),
          // Mobile list view with expandable categories
          ...expandableRows.map((expandableRow) {
            return ExpandableMobileCategoryItem(
              category: expandableRow.category,
              children: expandableRow.children,
              isExpanded: expandableRow.isExpanded,
              onToggle: () => onToggleExpand(expandableRow.category.id),
              onEdit: onEdit,
              onDelete: onDelete,
            );
          }),
        ],
      ),
    );
  }
}
