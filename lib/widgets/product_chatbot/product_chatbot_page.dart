import 'package:flutter/material.dart';

import 'product_chatbot_body.dart';

/// Màn đầy đủ [/chat] (deep link / điều hướng trực tiếp).
class ProductChatbotPage extends StatelessWidget {
  const ProductChatbotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductChatbotBody(displayMode: ChatDisplayMode.fullRoute);
  }
}
