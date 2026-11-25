import 'package:intl/intl.dart';

/// Tiện ích format tiền tệ VNĐ
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _vndFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  /// 120000 → "120.000 đ"
  static String format(double amount) {
    return _vndFormat.format(amount);
  }

  /// Tính % giảm giá  (originalPrice → price)
  static int discountPercent(double originalPrice, double price) {
    if (originalPrice <= 0) return 0;
    return (((originalPrice - price) / originalPrice) * 100).round();
  }
}
