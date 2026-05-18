import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/chatbot_config.dart';
import '../models/chatbot_models.dart';

class ChatbotException implements Exception {
  final String message;
  ChatbotException(this.message);

  @override
  String toString() => message;
}

class ChatbotService {
  ChatbotService();

  Future<ChatbotReply> sendMessages(List<ChatTurn> messages) async {
    final url = ChatbotConfig.productChatbotUrl;
    if (url.isEmpty) {
      throw ChatbotException(
        'Chưa cấu hình PRODUCT_CHATBOT_URL. Thêm --dart-define khi build hoặc chạy.',
      );
    }

    final uri = Uri.parse(url);
    final body = jsonEncode({
      'messages': messages.map((m) => m.toJson()).toList(),
    });

    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 90));

    if (response.statusCode != 200) {
      String detail = response.body;
      try {
        final err = jsonDecode(response.body);
        if (err is Map && err['error'] != null) {
          detail = err['error'].toString();
        }
      } catch (_) {}
      throw ChatbotException(
        'Chatbot lỗi (${response.statusCode}): $detail',
      );
    }

    try {
      final map = jsonDecode(response.body);
      if (map is! Map<String, dynamic>) {
        throw ChatbotException('Phản hồi không hợp lệ.');
      }
      return ChatbotReply.fromJson(map);
    } catch (e) {
      if (e is ChatbotException) rethrow;
      throw ChatbotException('Không đọc được phản hồi: $e');
    }
  }
}
