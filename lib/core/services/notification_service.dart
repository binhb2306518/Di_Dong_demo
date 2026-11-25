import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/currency_formatter.dart';

/// Dịch vụ quản lý Local Notifications trên Android
class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  NotificationService._init();

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Xử lý khi người dùng chạm vào thông báo
      },
    );

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    final androidImpl = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }
  }

  NotificationDetails _getOrderNotificationDetails() {
    const androidDetails = AndroidNotificationDetails(
      'bookverse_orders_channel',
      'Đơn hàng BookVerse',
      channelDescription: 'Thông báo cập nhật tiến độ đơn hàng BookVerse',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
    return const NotificationDetails(android: androidDetails);
  }

  /// Bắn thông báo khi đặt hàng thành công
  Future<void> showOrderSuccessNotification({
    required String orderId,
    required double totalAmount,
  }) async {
    await initialize();
    final details = _getOrderNotificationDetails();
    await _notificationsPlugin.show(
      orderId.hashCode,
      '🎉 Đặt hàng thành công!',
      'Đơn hàng #$orderId (${CurrencyFormatter.format(totalAmount)}) đang được xử lý và sẽ sớm giao đến bạn.',
      details,
      payload: orderId,
    );
  }

  /// Bắn thông báo khi trạng thái đơn hàng thay đổi
  Future<void> showOrderStatusUpdateNotification({
    required String orderId,
    required String status,
  }) async {
    await initialize();
    final details = _getOrderNotificationDetails();
    await _notificationsPlugin.show(
      orderId.hashCode + 1,
      '📦 Cập nhật đơn hàng #$orderId',
      'Trạng thái đơn hàng của bạn đã chuyển sang: "$status".',
      details,
      payload: orderId,
    );
  }

  /// Thông báo khuyến mãi hoặc nhắc nhở
  Future<void> showPromotionNotification({
    required String title,
    required String body,
  }) async {
    await initialize();
    const promoDetails = AndroidNotificationDetails(
      'bookverse_promo_channel',
      'Khuyến mãi & Tin tức',
      channelDescription: 'Thông báo mã giảm giá và sách mới',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      const NotificationDetails(android: promoDetails),
    );
  }
}
