// notificaciones_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> mostrarNotificacionFactura() async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'canal_factura', // ID del canal
    'Notificaciones de Facturas',
    channelDescription: 'Notificación tras crear factura',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails generalNotificationDetails = NotificationDetails(
    android: androidDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    '✅ Factura creada exitosamente',
    'Tu factura ha sido registrada.',
    generalNotificationDetails,
  );
}

