import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/product_model.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductModel product;
  final bool isMobile;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.isMobile,
  });

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  List<String> _getProductImages() {
    final images = <String>[];
    if (product.imageUrl != null) {
      images.add(product.imageUrl!);
    }
    if (product.imageUrls != null) {
      images.addAll(product.imageUrls!);
    }
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final images = _getProductImages();
    final discount = product.discount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image and basic info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              if (images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: images.first,
                    width: isMobile ? 60 : 80,
                    height: isMobile ? 60 : 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: isMobile ? 60 : 80,
                      height: isMobile ? 60 : 80,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 1),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: isMobile ? 60 : 80,
                      height: isMobile ? 60 : 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                )
              else
                Container(
                  width: isMobile ? 60 : 80,
                  height: isMobile ? 60 : 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              const SizedBox(width: 12),
              // Product details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 13 : 14,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Price
                    Row(
                      children: [
                        Text(
                          '${_formatPrice(product.price)} đ',
                          style: TextStyle(
                            fontSize: isMobile ? 13 : 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${_formatPrice(product.originalPrice)} đ',
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: Colors.grey[600],
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-$discount%',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Status and quantity
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: product.calculatedStatus == 'Còn hàng'
                                ? Colors.green[100]
                                : Colors.red[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.calculatedStatus,
                            style: TextStyle(
                              fontSize: 10,
                              color: product.calculatedStatus == 'Còn hàng'
                                  ? Colors.green[700]
                                  : Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SL: ${product.quantity}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (product.sold > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Đã bán: ${product.sold}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Product ID
          const SizedBox(height: 8),
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Mã SP:',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                product.id,
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

