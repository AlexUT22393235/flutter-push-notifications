import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/notifications/notificacion_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('Should be overridden in main.dart');
});

final badgeCountProvider = StateProvider<int>((_) => 0);