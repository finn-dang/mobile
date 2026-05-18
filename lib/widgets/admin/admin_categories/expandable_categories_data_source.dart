import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'expandable_category_row.dart';
import '../../../models/category_model.dart';

class ExpandableCategoriesDataSource extends DataTableSource {
  final List<ExpandableCategoryRow> expandableRows;
  final BuildContext context;
  final Function(CategoryModel) onEdit;
  final Function(CategoryModel) onDelete;
  final Function(String) onToggleExpand;

  ExpandableCategoriesDataSource({
    required this.expandableRows,
    required this.context,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleExpand,
  });

  @override
  DataRow? getRow(int index) {
    int currentIndex = 0;
    
    for (final expandableRow in expandableRows) {
      if (currentIndex == index) {
        // Return parent row
        return ExpandableCategoryDataRow(
          expandableRow: expandableRow,
          context: context,
          onEdit: onEdit,
          onDelete: onDelete,
          onToggleExpand: () => onToggleExpand(expandableRow.category.id),
        );
      }
      currentIndex++;

      // If expanded, add child rows
      if (expandableRow.isExpanded) {
        for (final child in expandableRow.children) {
          if (currentIndex == index) {
            return ChildCategoryDataRow(
              category: child,
              parentName: expandableRow.category.name,
              context: context,
              onEdit: onEdit,
              onDelete: onDelete,
            );
          }
          currentIndex++;
        }
      }
    }

    return null;
  }

  @override
  int get rowCount {
    int count = expandableRows.length;
    for (final row in expandableRows) {
      if (row.isExpanded) {
        count += row.children.length;
      }
    }
    return count;
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}

