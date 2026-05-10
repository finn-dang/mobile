/// URL HTTPS của Cloud Function [productChatbot] sau khi deploy (thường là Cloud Run, **không** thêm path).
/// Build: `flutter build web --dart-define=PRODUCT_CHATBOT_URL=https://...`
class ChatbotConfig {
  ChatbotConfig._();

  static const String productChatbotUrl = String.fromEnvironment(
    'PRODUCT_CHATBOT_URL',
    defaultValue: 'https://productchatbot-tqzehw7dna-as.a.run.app',
  );

  static bool get isConfigured => productChatbotUrl.isNotEmpty;
}
