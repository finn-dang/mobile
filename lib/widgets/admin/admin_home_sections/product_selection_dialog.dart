import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

class ProductSelectionDialog extends StatefulWidget {
  final List<String> selectedProductIds;

  const ProductSelectionDialog({
    super.key,
    required this.selectedProductIds,
  });

  @override
  State<ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  final _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedProductIds);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelection(String productId) {
    setState(() {
      if (_selectedIds.contains(productId)) {
        _selectedIds.remove(productId);
      } else {
        _selectedIds.add(productId);
      }
    });
  }

  void _handleConfirm() {
    Navigator.of(context).pop(_selectedIds.toList());
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        height: 600,
        child: Column(
          children: [
            AppBar(
              title: const Text('Chọn sản phẩm cho bộ sưu tập'),
              automaticallyImplyLeading: false,
              actions: [
                TextButton(
                  onPressed: _handleConfirm,
                  child: Text('Lưu chọn (${_selectedIds.length})'),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _productService.getProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Lỗi: ${snapshot.error}'),
                    );
                  }

                  final allProducts = snapshot.data ?? [];
                  final searchQuery = _searchController.text.toLowerCase();
                  final filteredProducts = allProducts.where((product) {
                    return searchQuery.isEmpty ||
                        product.name.toLowerCase().contains(searchQuery);
                  }).toList();

                  if (filteredProducts.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy sản phẩm'),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final isSelected = _selectedIds.contains(product.id);

                      return CheckboxListTile(
                        value: isSelected,
                        onChanged: (_) => _toggleSelection(product.id),
                        title: Text(product.name),
                        subtitle: Text('${_formatPrice(product.price)} đ'),
                        secondary: product.imageUrl != null
                            ? SizedBox(
                                width: 50,
                                height: 50,
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.image),
                                ),
                              )
                            : const Icon(Icons.image),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

