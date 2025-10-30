import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/notifications/notificacion_service.dart';
import 'features/home/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications before runApp
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        notificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const TurismoApp(),
    ),
  );
}
