import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  static const destinos = [
    {'nombre': 'Cancún', 'tipo': 'Playa'},
    {'nombre': 'Tulum', 'tipo': 'Zona arqueológica'},
    {'nombre': 'Bacalar', 'tipo': 'Laguna'},
    {'nombre': 'Isla Mujeres', 'tipo': 'Isla'},
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badge = ref.watch(badgeCountProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Destinos ($badge)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () async {
              print('🎯 Botón de notificación presionado');
              try {
                await ref
                    .read(notificationServiceProvider)
                    .showLocal(
                      title: 'Novedad turística',
                      body: 'Nueva promo en Quintana Roo 🌴',
                      payload: '/promo',
                    );
                ref.read(badgeCountProvider.notifier).state++;
                print('✅ Notificación inmediata enviada');
              } catch (e) {
                print('❌ Error en notificación inmediata: $e');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () async {
              print('🎯 Botón de notificación programada presionado');
              try {
                final scheduledTime = DateTime.now().add(
                  const Duration(seconds: 5),
                );
                await ref
                    .read(notificationServiceProvider)
                    .scheduleNotification(
                      title: 'Recordatorio de Viaje',
                      body: '¡No olvides revisar nuestras nuevas ofertas! 🏖️',
                      scheduledDate: scheduledTime,
                      payload: '/ofertas',
                    );
                print('✅ Notificación programada para: $scheduledTime');
              } catch (e) {
                print('❌ Error en notificación programada: $e');
              }
            },
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: destinos.length,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (_, i) {
          final d = destinos[i];
          return ListTile(
            leading: const Icon(Icons.place),
            title: Text(d['nombre']!),
            subtitle: Text(d['tipo']!),
            onTap: () async {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enviando notificación...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                await ref
                    .read(notificationServiceProvider)
                    .showLocal(
                      title: 'Explora ${d['nombre']}',
                      body: 'Descubre ${d['nombre']} (${d['tipo']})',
                      payload: '/destino/${d['nombre']}',
                    );
                ref.read(badgeCountProvider.notifier).state++;

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Notificación enviada!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
