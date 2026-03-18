import 'package:flutter/material.dart';

import '../../../config/colors.dart';
import '../../../config/spacing.dart';
import '../../../models/category_model.dart';

/// Sidebar filter cho trang Products – Modern Minimal.
///
/// Bao gồm: tìm kiếm, danh mục cha + con (expandable), khoảng giá, nút reset.
class FilterSidebar extends StatelessWidget {
  final TextEditingController searchController;
  final List<CategoryModel> parentCategories;
  final List<CategoryModel> childCategories;
  final String? selectedParentId;
  final String? selectedChildId;
  final ValueChanged<String?> onParentSelected;
  final ValueChanged<String?> onChildSelected;
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceChanged;
  final VoidCallback onReset;
  final int totalResults;

  const FilterSidebar({
    super.key,
    required this.searchController,
    required this.parentCategories,
    required this.childCategories,
    required this.selectedParentId,
    required this.selectedChildId,
    required this.onParentSelected,
    required this.onChildSelected,
    required this.priceRange,
    required this.minPrice,
    required this.maxPrice,
    required this.onPriceChanged,
    required this.onReset,
    required this.totalResults,
  });

  String _formatPrice(int p) => p.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );

  bool get _hasFilter =>
      selectedParentId != null ||
      selectedChildId != null ||
      searchController.text.isNotEmpty ||
      (maxPrice > minPrice &&
          (priceRange.start > minPrice || priceRange.end < maxPrice));

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.adminBorder),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(hasFilter: _hasFilter, onReset: onReset),
            const SizedBox(height: AppSpacing.md),
            _SectionHeader(label: 'Tìm kiếm'),
            const SizedBox(height: 6),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: searchController,
              builder: (_, value, __) =>
                  _SearchInput(controller: searchController),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionHeader(label: 'Danh mục'),
            const SizedBox(height: 6),
            _CategoryItem(
              label: 'Tất cả sản phẩm',
              icon: Icons.apps_rounded,
              isSelected: selectedParentId == null,
              onTap: () {
                onParentSelected(null);
                onChildSelected(null);
              },
            ),
            for (final p in parentCategories)
              _CategoryGroup(
                parent: p,
                isSelected: selectedParentId == p.id,
                children: childCategories
                    .where((c) => c.parentId == p.id)
                    .toList(),
                selectedChildId: selectedChildId,
                onParentTap: () {
                  if (selectedParentId == p.id) {
                    onParentSelected(null);
                    onChildSelected(null);
                  } else {
                    onParentSelected(p.id);
                    onChildSelected(null);
                  }
                },
                onChildTap: onChildSelected,
              ),
            if (maxPrice > minPrice) ...[
              const SizedBox(height: AppSpacing.lg),
              _SectionHeader(label: 'Khoảng giá'),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbColor: AppColors.surface,
                  activeTrackColor: AppColors.primary500,
                  inactiveTrackColor: AppColors.neutral200,
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                  rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                ),
                child: RangeSlider(
                  values: priceRange,
                  min: minPrice,
                  max: maxPrice,
                  divisions: 100,
                  onChanged: onPriceChanged,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PriceLabel(value: _formatPrice(priceRange.start.round())),
                    Container(
                      width: 16,
                      height: 1,
                      color: AppColors.neutral300,
                    ),
                    _PriceLabel(value: _formatPrice(priceRange.end.round())),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: AppColors.primary700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$totalResults sản phẩm phù hợp',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback onReset;
  const _Header({required this.hasFilter, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.tune_rounded,
          size: 16,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: 8),
        const Text(
          'Bộ lọc',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const Spacer(),
        if (hasFilter)
          TextButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: const Text('Đặt lại'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary600,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.adminGroupLabel,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  const _SearchInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontSize: 13.5,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Tên sản phẩm...',
          hintStyle: const TextStyle(
            fontSize: 13.5,
            color: AppColors.neutral400,
          ),
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceMuted,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 10, right: 4),
            child: Icon(
              Icons.search_rounded,
              size: 18,
              color: AppColors.neutral400,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  iconSize: 16,
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.neutral500,
                  ),
                  onPressed: () => controller.clear(),
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: _border(Colors.transparent),
          enabledBorder: _border(Colors.transparent),
          focusedBorder: _border(AppColors.primary500, width: 1.5),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _CategoryItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryItem> createState() => _CategoryItemState();
}

class _CategoryItemState extends State<_CategoryItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppColors.primary600
        : (_hover ? AppColors.textPrimary : AppColors.textSecondary);
    return Material(
      color: widget.isSelected
          ? AppColors.primary50
          : (_hover ? AppColors.surfaceMuted : Colors.transparent),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 9,
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  final CategoryModel parent;
  final bool isSelected;
  final List<CategoryModel> children;
  final String? selectedChildId;
  final VoidCallback onParentTap;
  final ValueChanged<String?> onChildTap;

  const _CategoryGroup({
    required this.parent,
    required this.isSelected,
    required this.children,
    required this.selectedChildId,
    required this.onParentTap,
    required this.onChildTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasChildren = children.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ParentTile(
          label: parent.name,
          isSelected: isSelected,
          hasChildren: hasChildren,
          onTap: onParentTap,
        ),
        if (isSelected && hasChildren)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.md, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ChildTile(
                  label: 'Tất cả ${parent.name}',
                  isSelected: selectedChildId == null,
                  onTap: () => onChildTap(null),
                ),
                for (final c in children)
                  _ChildTile(
                    label: c.name,
                    isSelected: selectedChildId == c.id,
                    onTap: () => onChildTap(c.id),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ParentTile extends StatefulWidget {
  final String label;
  final bool isSelected;
  final bool hasChildren;
  final VoidCallback onTap;

  const _ParentTile({
    required this.label,
    required this.isSelected,
    required this.hasChildren,
    required this.onTap,
  });

  @override
  State<_ParentTile> createState() => _ParentTileState();
}

class _ParentTileState extends State<_ParentTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppColors.primary600
        : (_hover ? AppColors.textPrimary : AppColors.textSecondary);
    return Material(
      color: widget.isSelected
          ? AppColors.primary50
          : (_hover ? AppColors.surfaceMuted : Colors.transparent),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 9,
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary500
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.primary500
                        : AppColors.adminBorder,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              if (widget.hasChildren)
                AnimatedRotation(
                  turns: widget.isSelected ? 0.25 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: color,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildTile extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ChildTile> createState() => _ChildTileState();
}

class _ChildTileState extends State<_ChildTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.surfaceMuted : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: widget.onTap,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 7,
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary500
                      : AppColors.neutral300,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? AppColors.primary600
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceLabel extends StatelessWidget {
  final String value;
  const _PriceLabel({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.adminBorder),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const TextSpan(
              text: ' ₫',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
