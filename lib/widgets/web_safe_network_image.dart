import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Ảnh từ URL (Firebase Storage, …).
///
/// Trên **web**, [CachedNetworkImage] tải bằng `fetch` → trình duyệt bắt **CORS**
/// (`Access-Control-Allow-Origin`). Nếu bucket chưa cấu hình CORS sẽ lỗi kiểu
/// `ERR_FAILED` dù HTTP 200.
///
/// Widget này trên web dùng [Image.network] với [WebHtmlElementStrategy.prefer]
/// (thẻ `<img>`) để hiển thị cross-origin **không phụ thuộc** CORS cho decode pixel.
/// Trên mobile/desktop vẫn dùng [CachedNetworkImage] (cache disk).
class WebSafeNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Widget Function(BuildContext context, String url)? placeholder;
  final Widget Function(BuildContext context, String url, Object error)?
      errorWidget;

  const WebSafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.color,
    this.colorBlendMode,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        color: color,
        colorBlendMode: colorBlendMode,
        webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
        loadingBuilder: placeholder == null
            ? null
            : (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return placeholder!(context, imageUrl);
              },
        errorBuilder: errorWidget == null
            ? null
            : (context, error, stackTrace) =>
                errorWidget!(context, imageUrl, error),
      );
    }
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
