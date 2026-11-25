/// Chuỗi hằng số chung cho toàn bộ ứng dụng BookVerse
class AppConstants {
  AppConstants._();

  static const String appName = 'BookVerse';
  static const String appTagline = 'Khám phá tri thức - Mua sách tiện lợi';

  // ── API / Backend ──
  static const String baseUrl = 'https://api.bookverse.local';
  static const String apiBaseUrl = 'https://api.bookverse.local';
  static const int connectTimeout = 15000; // ms
  static const int receiveTimeout = 15000;

  // ── SQLite ──
  static const String dbName = 'bookverse.db';
  static const int dbVersion = 1;

  // ── SharedPreferences keys ──
  static const String keyThemeMode = 'theme_mode';
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';

  // ── Payment Methods ──
  static const String paymentCOD = 'COD';
  static const String paymentVietQR = 'VietQR';

  // ── Voucher codes (mock) ──
  static const Map<String, dynamic> voucherCodes = {
    'BOOK10': {'type': 'percent', 'value': 10, 'label': 'Giảm 10%'},
    'BOOK20': {'type': 'percent', 'value': 20, 'label': 'Giảm 20%'},
    'FREESHIP': {'type': 'fixed', 'value': 30000, 'label': 'Giảm 30.000đ ship'},
    'WELCOME': {'type': 'fixed', 'value': 50000, 'label': 'Giảm 50.000đ'},
  };

  // ── Order Statuses ──
  static const String orderPending = 'Pending';
  static const String orderProcessing = 'Processing';
  static const String orderShipping = 'Shipping';
  static const String orderDelivered = 'Delivered';
  static const String orderCancelled = 'Cancelled';
}
