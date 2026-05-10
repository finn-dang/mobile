/// URL Cloud Function tạo link PayOS (Gen2, region asia-southeast1).
///
/// Override khi deploy: `--dart-define=PAYOS_CREATE_LINK_URL=https://...`
class PayosConfig {
  PayosConfig._();

  static const createPaymentLinkUrl = String.fromEnvironment(
    'PAYOS_CREATE_LINK_URL',
    defaultValue:
        'https://asia-southeast1-figurestore-68028.cloudfunctions.net/payosCreatePaymentLink',
  );
}
