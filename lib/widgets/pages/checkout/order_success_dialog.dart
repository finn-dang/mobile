// Modern Minimal – Dialog xác nhận đặt hàng thành công.
//
// Header có icon success container, các action buttons primary cam và
// secondary outline. Phần QR code (MoMo/Bank) giữ logic cũ, chỉ làm sạch
// container styling.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../../../../config/colors.dart';
import '../../../../config/spacing.dart';
import '../../../../models/cart_model.dart';
import '../../../../models/order_model.dart';
import '../../../../models/payment_method.dart';
import '../../../../models/payment_settings_model.dart';
import '../../../../services/payment_settings_service.dart';
import '../../web_safe_network_image.dart';

class OrderSuccessDialog extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessDialog({
    super.key,
    required this.order,
  });

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  bool _shouldShowQRCode() {
    return order.paymentMethod == PaymentMethod.momo;
  }

  String _getQRCodeTitle() {
    switch (order.paymentMethod) {
      case PaymentMethod.momo:
        return 'Quét mã QR MoMo để thanh toán';
      case PaymentMethod.cod:
      case PaymentMethod.payos:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final settingsFuture = PaymentSettingsService().getSettings();

    return FutureBuilder<PaymentSettingsModel>(
      future: settingsFuture,
      builder: (context, snapshot) {
        final paymentSettings = snapshot.data ?? PaymentSettingsModel.defaults();

        if (isMobile) {
          return _MobileOrderSuccessDialog(
            order: order,
            formatPrice: _formatPrice,
            shouldShowQRCode: _shouldShowQRCode(),
            qrCodeTitle: _getQRCodeTitle(),
            momoName: paymentSettings.momoName,
            momoPhone: paymentSettings.momoPhone,
            momoQrImageUrl: paymentSettings.momoQrImageUrl,
          );
        }

        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl2),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1100),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header – success badge
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.successContainer,
                          borderRadius: BorderRadius.circular(AppRadius.xl2),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 24,
                          color: AppColors.successDark,
                        ),
                      ),
                      AppSpacing.gapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Đặt hàng thành công!',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.4,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Cảm ơn bạn đã mua sắm. Chúng tôi sẽ liên hệ sớm để xác nhận đơn.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.neutral500,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Order code button
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt, color: Colors.blue[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Mã đơn hàng: ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            order.orderCode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Main content: 2 columns
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: Products
                      Expanded(
                        flex: 2,
                        child: _ProductsSection(order: order, formatPrice: _formatPrice),
                      ),
                      const SizedBox(width: 24),
                      // Right column: Recipient info, Payment, Summary, QR Code
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _RecipientInfoSection(order: order),
                            const SizedBox(height: 16),
                            // QR Code section (only for MoMo)
                            if (_shouldShowQRCode()) ...[
                              const SizedBox(height: 16),
                              _QRCodeSection(
                                title: _getQRCodeTitle(),
                                orderCode: order.orderCode,
                                total: order.total,
                                formatPrice: _formatPrice,
                                momoName: paymentSettings.momoName,
                                momoPhone: paymentSettings.momoPhone,
                                momoQrImageUrl: paymentSettings.momoQrImageUrl,
                              ),
                            ],
                            if (!_shouldShowQRCode()) ...[
                              const SizedBox(height: 16),
                              _PaymentMethodSection(order: order),
                            ],
                            const SizedBox(height: 16),
                            _OrderSummarySection(
                              order: order,
                              formatPrice: _formatPrice,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapXl,
                  // Footer actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _DesktopSecondaryButton(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Tiếp tục mua sắm',
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/');
                        },
                      ),
                      AppSpacing.gapMd,
                      _DesktopPrimaryButton(
                        icon: Icons.receipt_long_outlined,
                        label: 'Xem đơn hàng',
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/orders');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductsSection extends StatelessWidget {
  final OrderModel order;
  final String Function(int) formatPrice;

  const _ProductsSection({
    required this.order,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Sản phẩm',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => _ProductItem(
                item: item,
                formatPrice: formatPrice,
              )),
        ],
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final CartItemModel item;
  final String Function(int) formatPrice;

  const _ProductItem({
    required this.item,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.imageUrl != null
                ? WebSafeNetworkImage(
                    imageUrl: item.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
          ),
          const SizedBox(width: 12),
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.selectedVersion != null || item.selectedColor != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (item.selectedVersion != null) item.selectedVersion,
                      if (item.selectedColor != null) item.selectedColor,
                    ].join(' - '),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${formatPrice(item.price)} đ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'x${item.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientInfoSection extends StatelessWidget {
  final OrderModel order;

  const _RecipientInfoSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Thông tin người nhận',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Họ tên', value: order.fullName),
          const SizedBox(height: 8),
          _InfoRow(label: 'Số điện thoại', value: order.phone),
          const SizedBox(height: 8),
          _InfoRow(label: 'Địa chỉ', value: order.address),
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final OrderModel order;

  const _PaymentMethodSection({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.wallet, color: Colors.grey[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Phương thức thanh toán',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.paymentMethod.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  final OrderModel order;
  final String Function(int) formatPrice;

  const _OrderSummarySection({
    required this.order,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiền hàng',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${formatPrice(order.subtotal)} đ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí vận chuyển',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '${formatPrice(order.shippingFee)} đ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.wallet, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tổng cộng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
                Text(
                  '${formatPrice(order.total)} đ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QRCodeSection extends StatelessWidget {
  final String title;
  final String orderCode;
  final int total;
  final String Function(int) formatPrice;
  final String momoName;
  final String momoPhone;
  final String? momoQrImageUrl;

  const _QRCodeSection({
    required this.title,
    required this.orderCode,
    required this.total,
    required this.formatPrice,
    required this.momoName,
    required this.momoPhone,
    this.momoQrImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.purple[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal layout: QR Code and Payment details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // QR Code image
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: (momoQrImageUrl != null && momoQrImageUrl!.trim().isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: WebSafeNetworkImage(
                          imageUrl: momoQrImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code, size: 60, color: Colors.grey[400]),
                              const SizedBox(height: 4),
                              Text(
                                'QR lỗi tải',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 4),
                          Text(
                            'Chưa có QR',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 16),
              // Payment details - compact
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Số điện thoại: ${momoPhone.trim().isEmpty ? '--' : momoPhone}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tên: ${momoName.trim().isEmpty ? '--' : momoName}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          children: [
                            Text(
                              'Nội dung: ',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                            Text(
                              orderCode,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 2,
                          runSpacing: 2,
                          children: [
                            Text(
                              'Số tiền: ',
                              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            ),
                            Text(
                              '${formatPrice(total)} đ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileOrderSuccessDialog extends StatelessWidget {
  final OrderModel order;
  final String Function(int) formatPrice;
  final bool shouldShowQRCode;
  final String qrCodeTitle;
  final String momoName;
  final String momoPhone;
  final String? momoQrImageUrl;

  const _MobileOrderSuccessDialog({
    required this.order,
    required this.formatPrice,
    required this.shouldShowQRCode,
    required this.qrCodeTitle,
    required this.momoName,
    required this.momoPhone,
    this.momoQrImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.blue[700], size: 24),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'HÓA ĐƠN ĐẶT HÀNG',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Thành công',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order code
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.receipt, color: Colors.blue[700], size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Mã đơn: ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              order.orderCode,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Products section
                    _ProductsSection(order: order, formatPrice: formatPrice),
                    const SizedBox(height: 16),
                    // Recipient info
                    _RecipientInfoSection(order: order),
                    const SizedBox(height: 16),
                    // QR Code or Payment method
                    if (shouldShowQRCode)
                      _MobileQRCodeSection(
                        title: qrCodeTitle,
                        orderCode: order.orderCode,
                        total: order.total,
                        formatPrice: formatPrice,
                        momoName: momoName,
                        momoPhone: momoPhone,
                        momoQrImageUrl: momoQrImageUrl,
                      )
                    else
                      _PaymentMethodSection(order: order),
                    const SizedBox(height: 16),
                    // Order summary
                    _OrderSummarySection(
                      order: order,
                      formatPrice: formatPrice,
                    ),
                  ],
                ),
              ),
            ),
            // Footer actions
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.xl2),
                  bottomRight: Radius.circular(AppRadius.xl2),
                ),
                border: Border(
                  top: BorderSide(color: AppColors.adminBorder),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _DesktopPrimaryButton(
                      icon: Icons.receipt_long_outlined,
                      label: 'Xem đơn hàng',
                      fullWidth: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/orders');
                      },
                    ),
                  ),
                  AppSpacing.gapSm,
                  SizedBox(
                    width: double.infinity,
                    child: _DesktopSecondaryButton(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Tiếp tục mua sắm',
                      fullWidth: true,
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/');
                      },
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

class _MobileQRCodeSection extends StatelessWidget {
  final String title;
  final String orderCode;
  final int total;
  final String Function(int) formatPrice;
  final String momoName;
  final String momoPhone;
  final String? momoQrImageUrl;

  const _MobileQRCodeSection({
    required this.title,
    required this.orderCode,
    required this.total,
    required this.formatPrice,
    required this.momoName,
    required this.momoPhone,
    this.momoQrImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Colors.purple[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // QR Code centered
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: (momoQrImageUrl != null && momoQrImageUrl!.trim().isNotEmpty)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: WebSafeNetworkImage(
                        imageUrl: momoQrImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code, size: 70, color: Colors.grey[400]),
                            const SizedBox(height: 4),
                            Text(
                              'QR lỗi tải',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code, size: 70, color: Colors.grey[400]),
                        const SizedBox(height: 4),
                        Text(
                          'Chưa có QR',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          // Payment details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Số điện thoại: ${momoPhone.trim().isEmpty ? '--' : momoPhone}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tên: ${momoName.trim().isEmpty ? '--' : momoName}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                Wrap(
                  children: [
                    Text(
                      'Nội dung: ',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                    Text(
                      orderCode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: [
                    Text(
                      'Số tiền: ',
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                    Text(
                      '${formatPrice(total)} đ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Modern Minimal action buttons (dùng cho footer cả desktop + mobile)
// ---------------------------------------------------------------------------

class _DesktopPrimaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;

  const _DesktopPrimaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  State<_DesktopPrimaryButton> createState() =>
      _DesktopPrimaryButtonState();
}

class _DesktopPrimaryButtonState extends State<_DesktopPrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.primary600 : AppColors.primary500,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.fullWidth ? AppSpacing.md : AppSpacing.lg,
            vertical: 12,
          ),
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopSecondaryButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool fullWidth;

  const _DesktopSecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  State<_DesktopSecondaryButton> createState() =>
      _DesktopSecondaryButtonState();
}

class _DesktopSecondaryButtonState extends State<_DesktopSecondaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _hover ? AppColors.surfaceMuted : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: widget.onPressed,
        onHover: (v) => setState(() => _hover = v),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: widget.fullWidth ? AppSpacing.md : AppSpacing.lg,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.adminBorder),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 16, color: AppColors.textPrimary),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

