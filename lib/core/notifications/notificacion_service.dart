import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Default notification settings
  static const androidDetails = AndroidNotificationDetails(
    'default_channel',
    'General',
    channelDescription: 'Canal de notificaciones generales',
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    visibility: NotificationVisibility.public,
    channelShowBadge: true,
    autoCancel: true,
    fullScreenIntent: true,
  );

  static const iosDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  static const defaultDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Configure platform specific settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    // ✅ SOLUCIÓN: Inicializar SIN onDidReceiveBackgroundNotificationResponse
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      // ❌ REMOVER esta línea que causa el error
      // onDidReceiveBackgroundNotificationResponse: _onNotificationTapped,
    );

    // Create the notification channel
    const channel = AndroidNotificationChannel(
      'default_channel',
      'General',
      description: 'Canal de notificaciones generales',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
      enableLights: true,
    );

    await _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Request permissions
    await _requestPermissions();

    _isInitialized = true;
    print('✅ Notificaciones inicializadas correctamente');
  }

  Future<void> _requestPermissions() async {
    // Request Android permissions
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    // Request iOS permissions
    final ios = _local
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      critical: true,
    );
  }

  void _onNotificationTapped(NotificationResponse details) {
    print('Notificación tocada: ${details.payload}');
    // You can add navigation or other logic here
  }

  /// Show an immediate notification
  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    await init();

    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    await _local.show(id, title, body, defaultDetails, payload: payload);
    print('🔔 Notificación enviada: $title');
  }

  /// Schedule a notification for a specific time
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await init();

    final id = DateTime.now().millisecondsSinceEpoch % 100000;
    await _local.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      defaultDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
    print('⏰ Notificación programada: $title');
  }

  /// Cancel all pending notifications
  Future<void> cancelAll() async {
    await _local.cancelAll();
    print('🗑️ Todas las notificaciones canceladas');
  }

  /// Cancel a specific notification
  Future<void> cancel(int id) async {
    await _local.cancel(id);
    print('🗑️ Notificación $id cancelada');
  }

  /// Get pending notification requests
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _local.pendingNotificationRequests();
  }
}