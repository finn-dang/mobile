import 'package:flutter/material.dart';

enum OrderStatus {
  pending('pending', 'Chờ xác nhận', 'Chờ xử lý', 'Chờ', Colors.orange),
  confirmed('confirmed', 'Đã xác nhận', 'Đã xác nhận', 'Đã xác nhận', Colors.teal),
  processing('processing', 'Đang xử lý', 'Đang xử lý', 'Đang xử lý', Colors.blue),
  delivering('delivering', 'Đang giao', 'Đang giao', 'Giao hàng', Colors.purple),
  completed('completed', 'Đã hoàn thành', 'Đã hoàn thành', 'Hoàn thành', Colors.green),
  cancelled('cancelled', 'Đã hủy', 'Đã hủy', 'Hủy bỏ', Colors.red);

  final String value; // Giá trị lưu trong Firebase
  final String displayName; // Tên hiển thị mặc định
  final String adminDisplayName; // Tên hiển thị cho admin
  final String customerDisplayName; // Tên hiển thị cho customer
  final Color color; // Màu hiển thị cho status

  const OrderStatus(
    this.value,
    this.displayName,
    this.adminDisplayName,
    this.customerDisplayName,
    this.color,
  );

  static OrderStatus? fromString(String? value) {
    if (value == null) return null;
    try {
      return OrderStatus.values.firstWhere(
        (status) => status.value == value,
      );
    } catch (e) {
      // Fallback: thử match với display name
      for (var status in OrderStatus.values) {
        if (status.displayName == value ||
            status.adminDisplayName == value ||
            status.customerDisplayName == value) {
          return status;
        }
      }
      return null;
    }
  }

  // Map từ các giá trị cũ sang enum
  static OrderStatus? fromLegacyString(String? value) {
    if (value == null) return null;
    
    // Map các giá trị cũ
    switch (value) {
      case 'Chờ xác nhận':
      case 'Chờ xử lý':
      case 'Chờ':
      case 'unpaid':
      case 'paid':
      case 'Chưa thanh toán':
      case 'Đã thanh toán':
        return OrderStatus.pending;
      case 'Đã xác nhận':
        return OrderStatus.confirmed;
      case 'Đang xử lý':
        return OrderStatus.processing;
      case 'Đang giao':
      case 'Giao hàng':
        return OrderStatus.delivering;
      case 'Đã hoàn thành':
      case 'Hoàn thành':
        return OrderStatus.completed;
      case 'Đã hủy':
      case 'Hủy bỏ':
        return OrderStatus.cancelled;
      default:
        return fromString(value);
    }
  }
}

