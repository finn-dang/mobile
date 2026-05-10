class ChatTurn {
  final String role;
  final String content;

  const ChatTurn({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ChatbotProductSuggestion {
  final String productId;
  final String reason;

  const ChatbotProductSuggestion({
    required this.productId,
    required this.reason,
  });

  factory ChatbotProductSuggestion.fromJson(Map<String, dynamic> json) {
    return ChatbotProductSuggestion(
      productId: json['productId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
    );
  }
}

class ChatbotReply {
  final String assistantMessage;
  final bool needsClarification;
  final List<ChatbotProductSuggestion> suggestedProducts;

  const ChatbotReply({
    required this.assistantMessage,
    required this.needsClarification,
    required this.suggestedProducts,
  });

  factory ChatbotReply.fromJson(Map<String, dynamic> json) {
    final raw = json['suggestedProducts'];
    final list = raw is List
        ? raw
            .map((e) => ChatbotProductSuggestion.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ))
            .where((s) => s.productId.isNotEmpty)
            .toList()
        : <ChatbotProductSuggestion>[];
    return ChatbotReply(
      assistantMessage: json['assistantMessage'] as String? ?? '',
      needsClarification: json['needsClarification'] as bool? ?? false,
      suggestedProducts: list,
    );
  }
}
