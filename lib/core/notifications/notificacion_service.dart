import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  static const _channelId = 'default_channel_v2';
  static const _channelName = 'General';
  static const _channelDesc = 'Canal de notificaciones generales';
  final _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize with default app icon
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(settings);
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      playSound: true,
    );
    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _local.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Muestra notificación con imagen remota (Big Picture)
  Future<void> showBigPicture({
    required String title,
    required String body,
    required String imageUrl,
    String? payload,
  }) async {
    await init();

    final bigPicture = BigPictureStyleInformation(
      ByteArrayAndroidBitmap.fromBase64String(
        imageUrl,
      ), // For testing with base64 images
      contentTitle: title,
      summaryText: body,
      hideExpandedLargeIcon: false,
    );

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      styleInformation: bigPicture,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await _local.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final enabled = await androidImplementation?.areNotificationsEnabled();
    return enabled ?? false;
  }
}
