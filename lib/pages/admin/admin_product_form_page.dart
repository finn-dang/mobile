import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../config/colors.dart';
import '../../config/spacing.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/category_service.dart';
import '../../services/image_service.dart';
import '../../services/product_service.dart';
import '../../widgets/admin/admin_products/action_buttons.dart';
import '../../widgets/admin/admin_products/product_info_tab.dart';
import '../../widgets/admin/admin_products/product_options_section.dart';
import '../../widgets/admin/admin_products/product_specifications_section.dart';
import '../../widgets/admin/common/admin_page_header.dart';

/// Trang Tạo / Sửa sản phẩm – Modern Minimal.
class AdminProductFormPage extends StatefulWidget {
  /// Null = create, có giá trị = edit.
  final String? productId;

  const AdminProductFormPage({super.key, this.productId});

  @override
  State<AdminProductFormPage> createState() => _AdminProductFormPageState();
}

class _AdminProductFormPageState extends State<AdminProductFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _categoryService = CategoryService();
  final _imageService = ImageService();

  late TabController _tabController;

  // Basic
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedParentCategoryId;
  String? _selectedChildCategoryId;
  String? _selectedStatus = 'Còn hàng';

  // Images
  final List<PlatformFile> _selectedImageFiles = [];
  final List<String> _imageUrls = [];

  // Versions / colors / options
  final List<String> _versions = [];
  final List<Map<String, dynamic>> _colors = [];
  final List<Map<String, dynamic>> _options = [];
  String? _selectedVersionForOption;
  String? _selectedColorForOption;
  int? _editingOptionIndex;

  // Specifications
  final List<Map<String, String>> _specifications = [];

  // Sub-controllers
  final _versionController = TextEditingController();
  final _colorNameController = TextEditingController();
  final _colorHexController = TextEditingController();
  final _optionOriginalPriceController = TextEditingController();
  final _optionDiscountController = TextEditingController();
  final _optionQuantityController = TextEditingController();
  final _specLabelController = TextEditingController();
  final _specValueController = TextEditingController();

  bool _isLoading = false;
  bool _isUploading = false;
  ProductModel? _existingProduct;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _quantityController.addListener(_revalidate);
    if (widget.productId != null) {
      _loadProductData();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    _versionController.dispose();
    _colorNameController.dispose();
    _colorHexController.dispose();
    _optionOriginalPriceController.dispose();
    _optionDiscountController.dispose();
    _optionQuantityController.dispose();
    _specLabelController.dispose();
    _specValueController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _revalidate() {
    if (_formKey.currentState != null) {
      _formKey.currentState!.validate();
    }
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _loadProductData() async {
    setState(() => _isLoading = true);
    try {
      final product = await _productService.getProductById(widget.productId!);
      if (!mounted) return;
      if (product == null) {
        _snack('Không tìm thấy sản phẩm', AppColors.error);
        context.go('/admin/products');
        return;
      }
      setState(() {
        _existingProduct = product;
        _nameController.text = product.name;
        _priceController.text = product.price.toString();
        _originalPriceController.text = product.originalPrice.toString();
        _quantityController.text = product.quantity.toString();
        _descriptionController.text = product.description ?? '';
        _selectedParentCategoryId = product.categoryId;
        _selectedChildCategoryId = product.childCategoryId;
        _selectedStatus = product.status;

        _imageUrls
          ..clear()
          ..addAll([
            if (product.imageUrl != null) product.imageUrl!,
            ...?product.imageUrls,
          ]);

        _versions
          ..clear()
          ..addAll(product.versions ?? const []);
        _colors
          ..clear()
          ..addAll(product.colors ?? const []);
        _options
          ..clear()
          ..addAll(product.options ?? const []);
        _specifications
          ..clear()
          ..addAll(product.specifications ?? const []);
      });
    } catch (e) {
      if (mounted) _snack('Lỗi khi tải dữ liệu: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Images
  // ---------------------------------------------------------------------------

  Future<void> _pickImages() async {
    try {
      final files = await _imageService.pickMultipleImages();
      if (files.isNotEmpty) {
        setState(() => _selectedImageFiles.addAll(files));
      }
    } catch (e) {
      if (mounted) _snack(e.toString(), AppColors.error);
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _selectedImageFiles.length) {
        _selectedImageFiles.removeAt(index);
      } else {
        _imageUrls.removeAt(index - _selectedImageFiles.length);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Versions / colors / options
  // ---------------------------------------------------------------------------

  void _addVersion() {
    final v = _versionController.text.trim();
    if (v.isEmpty) return;
    if (_versions.contains(v)) {
      _snack('Phiên bản này đã tồn tại', AppColors.warning);
      return;
    }
    setState(() {
      _versions.add(v);
      _versionController.clear();
    });
  }

  void _removeVersion(int index) {
    setState(() {
      final v = _versions[index];
      _versions.removeAt(index);
      _options.removeWhere((o) => o['version'] == v);
    });
  }

  void _addColor() {
    final name = _colorNameController.text.trim();
    var hex = _colorHexController.text.trim();
    if (name.isEmpty || hex.isEmpty) return;
    if (!hex.startsWith('#')) hex = '#$hex';
    if (!RegExp(r'^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$').hasMatch(hex)) {
      _snack('Mã màu không hợp lệ. VD: #FF0000', AppColors.warning);
      return;
    }
    if (_colors.any((c) => c['name'] == name)) {
      _snack('Màu sắc này đã tồn tại', AppColors.warning);
      return;
    }
    setState(() {
      _colors.add({'name': name, 'hex': hex});
      _colorNameController.clear();
      _colorHexController.clear();
    });
  }

  void _removeColor(int index) {
    setState(() {
      final name = _colors[index]['name'] as String;
      _colors.removeAt(index);
      _options.removeWhere((o) => o['colorName'] == name);
    });
  }

  void _addOption() {
    if (_selectedVersionForOption == null ||
        _selectedVersionForOption!.isEmpty) {
      _snack('Vui lòng chọn phiên bản', AppColors.warning);
      return;
    }
    if (_selectedColorForOption == null ||
        _selectedColorForOption!.isEmpty) {
      _snack('Vui lòng chọn màu sắc', AppColors.warning);
      return;
    }

    final isDuplicate = _options.asMap().entries.any((e) =>
        e.key != _editingOptionIndex &&
        e.value['version'] == _selectedVersionForOption &&
        e.value['colorName'] == _selectedColorForOption);
    if (isDuplicate) {
      _snack('Tuỳ chọn này đã tồn tại', AppColors.warning);
      return;
    }

    final color =
        _colors.firstWhere((c) => c['name'] == _selectedColorForOption);
    final basePrice = int.tryParse(_priceController.text.trim()) ?? 0;
    final originalText = _optionOriginalPriceController.text.trim();
    final discountText = _optionDiscountController.text.trim();
    final originalPrice = originalText.isNotEmpty
        ? (int.tryParse(originalText) ?? basePrice)
        : basePrice;
    final discount =
        discountText.isNotEmpty ? (int.tryParse(discountText) ?? 0) : 0;

    if (discount < 0 || discount > 100) {
      _snack('Giảm giá phải từ 0 đến 100%', AppColors.warning);
      return;
    }

    final qtyText = _optionQuantityController.text.trim();
    if (qtyText.isEmpty) {
      _snack('Vui lòng nhập số lượng', AppColors.warning);
      return;
    }
    final qty = int.tryParse(qtyText);
    if (qty == null || qty < 0) {
      _snack('Số lượng phải là số nguyên ≥ 0', AppColors.warning);
      return;
    }

    final data = <String, dynamic>{
      'version': _selectedVersionForOption,
      'colorName': _selectedColorForOption,
      'colorHex': color['hex'] as String,
      'originalPrice': originalPrice,
      'discount': discount,
      'quantity': qty,
    };

    setState(() {
      if (_editingOptionIndex != null) {
        _options[_editingOptionIndex!] = data;
        _editingOptionIndex = null;
      } else {
        _options.add(data);
      }
      _selectedVersionForOption = null;
      _selectedColorForOption = null;
      _optionOriginalPriceController.clear();
      _optionDiscountController.clear();
      _optionQuantityController.clear();
    });
    _revalidate();
  }

  void _editOption(int index) {
    if (index < 0 || index >= _options.length) return;
    final o = _options[index];
    setState(() {
      _editingOptionIndex = index;
      _selectedVersionForOption = o['version'] as String;
      _selectedColorForOption = o['colorName'] as String;
      _optionOriginalPriceController.text =
          (o['originalPrice'] as int).toString();
      _optionDiscountController.text = (o['discount'] as int).toString();
      _optionQuantityController.text = (o['quantity'] as int? ?? 0).toString();
    });
  }

  void _cancelEditOption() {
    setState(() {
      _editingOptionIndex = null;
      _selectedVersionForOption = null;
      _selectedColorForOption = null;
      _optionOriginalPriceController.clear();
      _optionDiscountController.clear();
      _optionQuantityController.clear();
    });
  }

  void _removeOption(int index) {
    setState(() => _options.removeAt(index));
    _revalidate();
  }

  // ---------------------------------------------------------------------------
  // Specifications
  // ---------------------------------------------------------------------------

  void _addSpecification() {
    final label = _specLabelController.text.trim();
    final value = _specValueController.text.trim();
    if (label.isEmpty || value.isEmpty) {
      _snack('Vui lòng nhập đủ tên và giá trị thông số', AppColors.warning);
      return;
    }
    setState(() {
      _specifications.add({'label': label, 'value': value});
      _specLabelController.clear();
      _specValueController.clear();
    });
  }

  void _removeSpecification(int index) {
    setState(() => _specifications.removeAt(index));
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedParentCategoryId == null) {
      _snack('Vui lòng chọn danh mục', AppColors.warning);
      return;
    }

    final qtyText = _quantityController.text.trim();
    if (qtyText.isNotEmpty) {
      final qty = int.tryParse(qtyText);
      if (qty != null && _options.isNotEmpty) {
        final total = _options.fold<int>(
          0,
          (s, o) => s + (o['quantity'] as int? ?? 0),
        );
        if (total != qty) {
          _tabController.animateTo(0);
          await Future.delayed(const Duration(milliseconds: 200));
          if (mounted) _formKey.currentState?.validate();
          if (mounted) {
            _snack(
              'Tổng số lượng options ($total) phải bằng số lượng ($qty)',
              AppColors.error,
            );
          }
          return;
        }
      }
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
    });

    try {
      final uploaded = <String>[];
      for (final f in _selectedImageFiles) {
        uploaded.add(await _imageService.uploadImage(
          platformFile: f,
          folder: 'products',
        ));
      }
      uploaded.addAll(_imageUrls);

      final mainImage = uploaded.isNotEmpty ? uploaded.first : null;
      final extraImages = uploaded.length > 1 ? uploaded.sublist(1) : null;

      final now = DateTime.now();
      final product = ProductModel(
        id: widget.productId ?? '',
        name: _nameController.text.trim(),
        categoryId: _selectedParentCategoryId!,
        childCategoryId: _selectedChildCategoryId,
        price: int.parse(_priceController.text.trim()),
        originalPrice: int.parse(
          _originalPriceController.text.trim().isEmpty
              ? _priceController.text.trim()
              : _originalPriceController.text.trim(),
        ),
        quantity: int.parse(_quantityController.text.trim()),
        status: _selectedStatus ?? 'Còn hàng',
        imageUrl: mainImage,
        imageUrls: extraImages,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        rating: _existingProduct?.rating ?? 0.0,
        sold: _existingProduct?.sold ?? 0,
        versions: _versions.isEmpty ? null : _versions,
        colors: _colors.isEmpty ? null : _colors,
        options: _options.isEmpty ? null : _options,
        specifications: _specifications.isEmpty ? null : _specifications,
        createdAt: _existingProduct?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.productId != null) {
        await _productService.updateProduct(widget.productId!, product);
      } else {
        await _productService.createProduct(product);
      }

      if (!mounted) return;
      context.go('/admin/products');
      _snack(
        widget.productId != null
            ? 'Cập nhật sản phẩm thành công!'
            : 'Tạo sản phẩm thành công!',
        AppColors.success,
      );
    } catch (e) {
      if (mounted) _snack('Lỗi: $e', AppColors.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (_isLoading && widget.productId != null && _existingProduct == null) {
      return _shellWithBody(const _LoadingState());
    }

    return StreamBuilder<List<CategoryModel>>(
      stream: _categoryService.getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            widget.productId == null) {
          return _shellWithBody(const _LoadingState());
        }
        if (snapshot.hasError) {
          return _shellWithBody(
            _ErrorState(
              message: snapshot.error.toString(),
              onBack: () => context.go('/admin/products'),
            ),
          );
        }

        final all = snapshot.data ?? const [];
        final parents = all.where((c) => c.parentId == null).toList();
        final children = all
            .where((c) => c.parentId == _selectedParentCategoryId)
            .toList();

        return _buildShell(
          isMobile: isMobile,
          isTablet: isTablet,
          body: Form(
            key: _formKey,
            child: TabBarView(
              controller: _tabController,
              children: [
                _tabContent(
                  isMobile: isMobile,
                  isTablet: isTablet,
                  child: ProductInfoTab(
                    nameController: _nameController,
                    priceController: _priceController,
                    originalPriceController: _originalPriceController,
                    quantityController: _quantityController,
                    descriptionController: _descriptionController,
                    selectedParentCategoryId: _selectedParentCategoryId,
                    selectedChildCategoryId: _selectedChildCategoryId,
                    selectedStatus: _selectedStatus,
                    parentCategories: parents,
                    childCategories: children,
                    onParentCategoryChanged: (v) => setState(() {
                      _selectedParentCategoryId = v;
                      _selectedChildCategoryId = null;
                    }),
                    onChildCategoryChanged: (v) =>
                        setState(() => _selectedChildCategoryId = v),
                    onStatusChanged: (v) =>
                        setState(() => _selectedStatus = v),
                    selectedImageFiles: _selectedImageFiles,
                    imageUrls: _imageUrls,
                    onPickImages: _pickImages,
                    onRemoveImage: _removeImage,
                    options: _options,
                    isUploading: _isUploading,
                    isTablet: isTablet,
                    isMobile: isMobile,
                  ),
                ),
                _tabContent(
                  isMobile: isMobile,
                  isTablet: isTablet,
                  child: ProductOptionsSection(
                    versions: _versions,
                    colors: _colors,
                    options: _options,
                    versionController: _versionController,
                    colorNameController: _colorNameController,
                    colorHexController: _colorHexController,
                    selectedVersionForOption: _selectedVersionForOption,
                    selectedColorForOption: _selectedColorForOption,
                    optionOriginalPriceController:
                        _optionOriginalPriceController,
                    optionDiscountController: _optionDiscountController,
                    optionQuantityController: _optionQuantityController,
                    basePrice:
                        int.tryParse(_priceController.text.trim()) ?? 0,
                    editingOptionIndex: _editingOptionIndex,
                    onVersionChanged: (v) =>
                        setState(() => _selectedVersionForOption = v),
                    onColorChanged: (v) =>
                        setState(() => _selectedColorForOption = v),
                    onAddVersion: _addVersion,
                    onRemoveVersion: _removeVersion,
                    onAddColor: _addColor,
                    onRemoveColor: _removeColor,
                    onAddOption: _addOption,
                    onEditOption: _editOption,
                    onCancelEditOption: _cancelEditOption,
                    onRemoveOption: _removeOption,
                    isTablet: isTablet,
                    isMobile: isMobile,
                  ),
                ),
                _tabContent(
                  isMobile: isMobile,
                  isTablet: isTablet,
                  child: ProductSpecificationsSection(
                    specifications: _specifications,
                    labelController: _specLabelController,
                    valueController: _specValueController,
                    onAddSpecification: _addSpecification,
                    onRemoveSpecification: _removeSpecification,
                    isTablet: isTablet,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Shell có header + tabBar + child body.
  Widget _buildShell({
    required bool isMobile,
    required bool isTablet,
    required Widget body,
  }) {
    final isEdit = widget.productId != null;
    final pageHorizontalPadding =
        isMobile ? AppSpacing.lg : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);

    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                pageHorizontalPadding,
                AppSpacing.lg,
                pageHorizontalPadding,
                AppSpacing.sm,
              ),
              child: AdminPageHeader(
                title: isEdit ? 'Chỉnh sửa sản phẩm' : 'Thêm sản phẩm mới',
                subtitle: isEdit
                    ? 'Cập nhật thông tin, tuỳ chọn và thông số kỹ thuật.'
                    : 'Điền thông tin sản phẩm trước khi đưa lên cửa hàng.',
                action: AdminSecondaryButton(
                  icon: Icons.arrow_back_rounded,
                  label: 'Quay lại',
                  onPressed: () => context.go('/admin/products'),
                ),
                dense: true,
              ),
            ),
            _MinimalTabBar(
              controller: _tabController,
              padding: EdgeInsets.symmetric(horizontal: pageHorizontalPadding),
              tabs: const ['Thông tin', 'Tuỳ chọn', 'Thông số'],
            ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _shellWithBody(Widget child) {
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      body: SafeArea(child: Center(child: child)),
    );
  }

  /// Content padding chuẩn cho mỗi tab + footer action buttons.
  Widget _tabContent({
    required bool isMobile,
    required bool isTablet,
    required Widget child,
  }) {
    final padding =
        isMobile ? AppSpacing.lg : (isTablet ? AppSpacing.xl2 : AppSpacing.xl3);
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        padding,
        AppSpacing.lg,
        padding,
        padding + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        children: [
          child,
          AppSpacing.gapXl,
          ActionButtons(
            isLoading: _isLoading,
            onSubmit: _handleSubmit,
            onCancel: () => context.go('/admin/products'),
            isMobile: isMobile,
            submitLabel:
                widget.productId != null ? 'Cập nhật' : 'Tạo sản phẩm',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab bar – Modern Minimal
// ---------------------------------------------------------------------------

class _MinimalTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final EdgeInsetsGeometry padding;

  const _MinimalTabBar({
    required this.controller,
    required this.tabs,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.adminBorder, width: 1),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelPadding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 0),
        labelColor: AppColors.primary600,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.1,
        ),
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.primary500, width: 2),
          insets: EdgeInsets.symmetric(horizontal: 4),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? AppColors.surfaceMuted
              : null,
        ),
        tabs: [
          for (final t in tabs)
            Tab(
              height: 44,
              child: Text(t),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State widgets
// ---------------------------------------------------------------------------

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(
        strokeWidth: 2.4,
        color: AppColors.primary500,
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onBack;
  const _ErrorState({required this.message, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(AppRadius.xl2),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 26,
              color: AppColors.errorDark,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Không thể tải dữ liệu',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AdminSecondaryButton(
            icon: Icons.arrow_back_rounded,
            label: 'Quay lại',
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}
