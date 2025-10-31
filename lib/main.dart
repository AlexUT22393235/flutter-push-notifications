import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/notifications/notificacion_service.dart';
import 'firebase_messaging_handler.dart';
import 'app.dart';

// Canales de notificación para Android
const fcmDefaultChannel = AndroidNotificationChannel(
  'default_channel_fcm',
  'General (FCM)',
  description: 'Canal por defecto para mensajes FCM',
  importance: Importance.high,
  playSound: true,
);

Future<void> getAndPrintToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("======= FCM TOKEN =======");
  print(token);
  print("=========================");
}


/// Función principal de la aplicación
Future<void> main() async {
  try {
    // Asegurar inicialización de Flutter
    WidgetsFlutterBinding.ensureInitialized();

   

    // Inicializar Firebase
    await Firebase.initializeApp();

    // Configurar manejador de mensajes en background
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Inicializar servicio de notificaciones locales
    final notificationService = NotificationService();
    await notificationService.init();

    await getAndPrintToken();


    // Configurar canal FCM y permisos
    await _ensureFcmDefaultChannel();
    await _requestPermissions();

    // Configurar manejadores de mensajes en foreground
    _configureForegroundHandlers(notificationService);

    // Iniciar la aplicación
    runApp(const ProviderScope(child: TurismoApp()));
  } catch (e) {
    log('Error en inicialización: $e');
    rethrow; // Relanzar para que el framework maneje el error
  }
}

/// Solicita permisos necesarios según la plataforma
Future<void> _requestPermissions() async {
  try {
    final messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      // Solicitar permisos en iOS
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } else if (Platform.isAndroid) {
      // Solicitar permisos en Android
      final androidImpl = FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImpl?.requestNotificationsPermission();

      // Obtener token FCM (opcional, para debug)
      final token = await messaging.getToken();
      log('FCM Token: $token');
    }
  } catch (e) {
    log('Error al solicitar permisos: $e');
    rethrow;
  }
}

/// Configura los manejadores de mensajes en primer plano
void _configureForegroundHandlers(NotificationService local) {
  // Manejar mensajes cuando la app está en primer plano
  FirebaseMessaging.onMessage.listen((message) async {
    try {
      final title = message.notification?.title ?? 'Mensaje';
      final body = message.notification?.body ?? 'Tienes una notificación';

      // Mostrar notificación local
      await local.showLocal(title: title, body: body);
    } catch (e) {
      log('Error al mostrar notificación: $e');
    }
  });

  // Manejar cuando se toca la notificación con la app en segundo plano
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    log('Notificación tocada (app en segundo plano): ${message.data}');
    // TODO: Implementar navegación según payload
  });
}

/// Asegura que exista el canal de notificaciones para FCM en Android
Future<void> _ensureFcmDefaultChannel() async {
  if (!Platform.isAndroid) return;

  try {
    final plugin = FlutterLocalNotificationsPlugin()
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await plugin?.createNotificationChannel(fcmDefaultChannel);
  } catch (e) {
    log('Error al crear canal FCM: $e');
    rethrow;
  }
}
