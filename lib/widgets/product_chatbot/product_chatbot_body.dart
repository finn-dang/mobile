import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/chatbot_config.dart';
import '../../config/colors.dart';
import '../../models/chatbot_models.dart';
import '../../models/product_model.dart';
import '../../services/chatbot_service.dart';
import '../../services/product_service.dart';
import '../web_safe_network_image.dart';

enum ChatDisplayMode { dock, fullRoute }

class _UiMessage {
  final bool isUser;
  final String text;
  final List<ChatbotProductSuggestion> suggestions;
  final List<ProductModel> products;

  const _UiMessage({
    required this.isUser,
    required this.text,
    this.suggestions = const [],
    this.products = const [],
  });

  _UiMessage copyWith({
    List<ProductModel>? products,
    List<ChatbotProductSuggestion>? suggestions,
  }) {
    return _UiMessage(
      isUser: isUser,
      text: text,
      suggestions: suggestions ?? this.suggestions,
      products: products ?? this.products,
    );
  }
}

/// Nội dung chat dùng chung cho dock góc phải và màn [/chat].
class ProductChatbotBody extends StatefulWidget {
  final ChatDisplayMode displayMode;
  final VoidCallback? onDockClose;

  const ProductChatbotBody({
    super.key,
    required this.displayMode,
    this.onDockClose,
  });

  @override
  State<ProductChatbotBody> createState() => _ProductChatbotBodyState();
}

class _ProductChatbotBodyState extends State<ProductChatbotBody> {
  final _service = ChatbotService();
  final _productService = ProductService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatTurn> _apiTurns = [];
  final List<_UiMessage> _uiMessages = [];
  bool _loading = false;

  // Fixed quick replies with proper text
  static const _quickReplies = [
    'Gợi ý outfit đi làm thanh lịch, dễ mặc mỗi ngày',
    'Mình cao 1m62 nặng 52kg, nên chọn size váy nào?',
    'Tư vấn set đồ đi cafe cuối tuần, ngân sách dưới 1.5 triệu',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _loading = true;
      _apiTurns.add(ChatTurn(role: 'user', content: text));
      _uiMessages.add(_UiMessage(isUser: true, text: text));
    });
    _controller.clear();
    _scrollToBottom();

    try {
      if (!ChatbotConfig.isConfigured) {
        throw ChatbotException(
          'Chưa cấu hình PRODUCT_CHATBOT_URL (URL Cloud Function sau khi deploy).',
        );
      }
      final reply = await _service.sendMessages(_apiTurns);
      _apiTurns.add(ChatTurn(role: 'assistant', content: reply.assistantMessage));

      final assistantIndex = _uiMessages.length;
      setState(() {
        _uiMessages.add(
          _UiMessage(
            isUser: false,
            text: reply.assistantMessage,
            suggestions: reply.suggestedProducts,
          ),
        );
      });
      _scrollToBottom();

      final ids = reply.suggestedProducts.map((s) => s.productId).toList();
      final products = <ProductModel>[];
      for (final id in ids) {
        final p = await _productService.getProductById(id);
        if (p != null) products.add(p);
      }
      if (!mounted) return;
      setState(() {
        if (assistantIndex < _uiMessages.length) {
          final m = _uiMessages[assistantIndex];
          _uiMessages[assistantIndex] = m.copyWith(products: products);
        }
      });
      _scrollToBottom();
    } on ChatbotException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiTurns.removeLast();
        _uiMessages.removeLast();
      });
      _showSnackbar(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiTurns.removeLast();
        _uiMessages.removeLast();
      });
      _showSnackbar('Lỗi: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _newChat() {
    setState(() {
      _apiTurns.clear();
      _uiMessages.clear();
    });
  }

  void _onLeadingPressed() {
    if (widget.displayMode == ChatDisplayMode.dock) {
      widget.onDockClose?.call();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    final titleStyle = widget.displayMode == ChatDisplayMode.dock
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary, // Changed to visible color
            )
        : Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary, // Changed to visible color
            );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            AppColors.primaryContainer.withOpacity(0.3),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with glass morphism effect
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                widget.displayMode == ChatDisplayMode.dock ? 4 : 16,
                widget.displayMode == ChatDisplayMode.dock ? 4 : 12,
                widget.displayMode == ChatDisplayMode.dock ? 4 : 12,
                0,
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        widget.displayMode == ChatDisplayMode.dock
                            ? Icons.close_rounded
                            : Icons.arrow_back_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: _onLeadingPressed,
                      tooltip: widget.displayMode == ChatDisplayMode.dock ? 'Đóng' : 'Quay lại',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Stylist ảo',
                          style: titleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton.icon(
                      onPressed: _uiMessages.isEmpty ? null : _newChat,
                      icon: Icon(
                        Icons.refresh_rounded,
                        size: 18,
                        color: _uiMessages.isEmpty ? Colors.grey.shade400 : AppColors.primary,
                      ),
                      label: Text(
                        'Mới',
                        style: TextStyle(
                          color: _uiMessages.isEmpty ? Colors.grey.shade400 : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Warning message if not configured
          if (!ChatbotConfig.isConfigured)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.warningContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warningDark, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Thiếu PRODUCT_CHATBOT_URL. Deploy Cloud Function productChatbot, '
                          'đặt secret GEMINI_API_KEY, rồi chạy app với --dart-define=PRODUCT_CHATBOT_URL=<URL HTTPS>.',
                          style: const TextStyle(fontSize: 12, height: 1.4, color: Colors.brown), // Added visible color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Chat messages area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bubbleMax = constraints.maxWidth * 0.88;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.primaryContainer.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    itemCount: _uiMessages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _uiMessages.length) {
                        if (_loading) {
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Stylist đang nghĩ...',
                                    style: TextStyle(fontSize: 13, color: AppColors.textPrimary), // Added visible color
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox(height: 6);
                      }
                      final m = _uiMessages[index];
                      return AnimatedOpacity(
                        opacity: 1,
                        duration: const Duration(milliseconds: 300),
                        child: _MessageTile(
                          isUser: m.isUser,
                          text: m.text,
                          products: m.products,
                          suggestions: m.suggestions,
                          onProductTap: (id) => context.push('/products/$id'),
                          formatPrice: _formatPrice,
                          maxBubbleWidth: bubbleMax,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          // Quick replies (shown when no messages) - FIXED COLORS FOR BETTER CONTRAST
          if (_uiMessages.isEmpty && !_loading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      '✨ Gợi ý câu hỏi:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700, // Darker for better visibility
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickReplies
                        .map(
                          (q) => Material(
                            elevation: 0,
                            borderRadius: BorderRadius.circular(24),
                            child: InkWell(
                              onTap: () => _send(q),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 300),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100, // Light gray background instead of light orange
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        q,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary, // Dark text for contrast
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          // Input area - FIXED TYPO AND OVERFLOW HERE
          SafeArea(
            top: false,
            child: AnimatedPadding(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.fromLTRB(
                12,
                8,
                12,
                12 +
                    (widget.displayMode == ChatDisplayMode.dock
                        ? 0
                        : keyboardBottom),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Hỏi về phối đồ, size, chất liệu...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          isDense: widget.displayMode == ChatDisplayMode.dock,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: widget.displayMode == ChatDisplayMode.dock ? 10 : 14,
                          ),
                        ),
                        onSubmitted: (_) => _send(_controller.text),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _loading
                              ? [Colors.grey.shade400, Colors.grey.shade500]
                              : [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: _loading
                            ? []
                            : [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: IconButton(
                        onPressed: _loading ? null : () => _send(_controller.text),
                        icon: Icon(
                          Icons.send_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          minimumSize: widget.displayMode == ChatDisplayMode.dock
                              ? const Size(48, 48)
                              : const Size(52, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final bool isUser;
  final String text;
  final List<ProductModel> products;
  final List<ChatbotProductSuggestion> suggestions;
  final void Function(String productId) onProductTap;
  final String Function(int) formatPrice;
  final double maxBubbleWidth;

  const _MessageTile({
    required this.isUser,
    required this.text,
    required this.products,
    required this.suggestions,
    required this.onProductTap,
    required this.formatPrice,
    required this.maxBubbleWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Fixed bubble colors for better contrast
    final bubbleColor = isUser 
        ? AppColors.primary  // Solid primary color for user messages
        : Colors.grey.shade100;  // Light gray for assistant messages
    final textColor = isUser 
        ? Colors.white  // White text on primary background (good contrast)
        : AppColors.textPrimary;  // Dark text on light background
    final align = isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: align,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Avatar row for assistant
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Stylist AI',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            // Message bubble
            Container(
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontSize: 14,
                        height: 1.4,
                      ),
                ),
              ),
            ),
            // Product suggestions
            if (!isUser && products.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  '✨ Gợi ý sản phẩm phù hợp:',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final p = products[i];
                    final reason = suggestions
                        .where((s) => s.productId == p.id)
                        .map((s) => s.reason)
                        .firstOrNull;
                    return _ProductCard(
                      product: p,
                      reason: reason,
                      formatPrice: formatPrice,
                      onTap: () => onProductTap(p.id),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final i = iterator;
    return i.moveNext() ? i.current : null;
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String? reason;
  final String Function(int) formatPrice;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.reason,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: url != null && url.isNotEmpty
                      ? WebSafeNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.borderLight,
                            child: const Icon(Icons.image_outlined, size: 30, color: Colors.grey),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.borderLight,
                            child: const Icon(Icons.broken_image, size: 30, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: AppColors.borderLight,
                          child: const Icon(Icons.image_outlined, size: 30, color: Colors.grey),
                        ),
                ),
              ),
              // Product info
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_money_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        Text(
                          formatPrice(product.price),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Text(' đ', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                      ],
                    ),
                    if (reason != null && reason!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 10,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                reason!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}