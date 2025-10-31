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
                print('✅ Notificación inmediata enviada');
              } catch (e) {
                print('❌ Error en notificación inmediata: $e');
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
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () async {
              print('🎯 Botón de notificación con imagen presionado');
              try {
                // Example base64 image (you should replace this with your actual image)
                const base64Image =
                    '/9j/4AAQSkZJRg...'; // Truncated for example
                await ref
                    .read(notificationServiceProvider)
                    .showBigPicture(
                      title: 'Destino destacado',
                      body: '¡Descubre la belleza de nuestros destinos! 🏖️',
                      imageUrl: base64Image,
                    );
                ref.read(badgeCountProvider.notifier).state++;

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Notificación con imagen enviada!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                print('✅ Notificación con imagen enviada');
              } catch (e) {
                print('❌ Error en notificación con imagen: $e');
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

                // Verificar si las notificaciones están habilitadas
                final enabled = await ref
                    .read(notificationServiceProvider)
                    .areNotificationsEnabled();

                if (!enabled && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Las notificaciones están desactivadas. Por favor, actívalas en la configuración.',
                      ),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                await ref
                    .read(notificationServiceProvider)
                    .showLocal(
                      title: 'Explora ${d['nombre']}',
                      body: 'Descubre ${d['nombre']} (${d['tipo']})',
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
