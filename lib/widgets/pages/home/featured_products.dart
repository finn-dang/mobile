import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

class FeaturedProducts extends StatelessWidget {
  const FeaturedProducts({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock products data
    final products = List.generate(6, (index) => {
      'id': 'product-$index',
      'name': 'Sản phẩm ${index + 1}',
      'originalPrice': (1500000 + index * 500000).toString(),
      'price': (1000000 + index * 500000).toString(),
      'discount': index % 3 == 0 ? 20 : (index % 3 == 1 ? 15 : 10),
      'badge': index % 4 == 0 ? 'Mới' : (index % 4 == 1 ? 'Bán chạy' : (index % 4 == 2 ? 'Hot' : 'Nổi bật')),
      'rating': 4.0 + (index % 5) * 0.2,
      'sold': 100 + index * 50,
      'image': 'https://images.unsplash.com/photo-1609692814858-f7cd2f0afa4f?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    });

    // Xác định số cột và aspect ratio dựa trên kích thước màn hình
    int crossAxisCount;
    double childAspectRatio;
    if (ResponsiveBreakpoints.of(context).isMobile) {
      crossAxisCount = 2; // Mobile: 2 cột
      childAspectRatio = 3/6; // Mobile: tỉ lệ thấp hơn để fit nội dung
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      crossAxisCount = 3; // Tablet: 3 cột
      childAspectRatio = 0.75;
    } else {
      crossAxisCount = 4; // Desktop: 4 cột
      childAspectRatio = 0.75;
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sản phẩm nổi bật',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: products.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final product = products[index];
              final isMobile = ResponsiveBreakpoints.of(context).isMobile;
              return Card(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go('/product/${product['id']}'),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Tính toán chiều cao hình ảnh dựa trên tỉ lệ
                      final imageHeight = constraints.maxHeight * 0.6;
                      final contentHeight = constraints.maxHeight * 0.4;
                      
                      final discount = product['discount'] as int;
                      final originalPrice = int.parse(product['originalPrice'] as String);
                      final price = int.parse(product['price'] as String);
                      final badge = product['badge'] as String;
                      final rating = product['rating'] as double;
                      final sold = product['sold'] as int;
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Container(
                                height: imageHeight,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    product['image'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image,
                                        size: isMobile ? 48 : 64,
                                        color: Colors.grey[400],
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              // Badge giảm giá
                              if (discount > 0)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '-$discount%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              // Highlight badge
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: badge == 'Mới' 
                                        ? Colors.green
                                        : badge == 'Bán chạy'
                                            ? Colors.orange
                                            : badge == 'Hot'
                                                ? Colors.red
                                                : Colors.blue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    badge,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: contentHeight,
                            padding: EdgeInsets.all(isMobile ? 12 : 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    product['name'] as String,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontSize: isMobile ? 14 : null,
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Rating và số lượng đã bán
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...List.generate(5, (index) {
                                      return Icon(
                                        index < rating.floor()
                                            ? Icons.star
                                            : (index < rating ? Icons.star_half : Icons.star_border),
                                        size: isMobile ? 12 : 14,
                                        color: Colors.amber,
                                      );
                                    }),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '($sold)',
                                        style: TextStyle(
                                          fontSize: isMobile ? 11 : 12,
                                          color: Colors.grey[600],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Giá
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_formatPrice(price)} đ',
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                              color: Theme.of(context).colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: isMobile ? 16 : 18,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (discount > 0) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${_formatPrice(originalPrice)} đ',
                                          style: TextStyle(
                                            fontSize: isMobile ? 12 : 14,
                                            color: Colors.grey[600],
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}

