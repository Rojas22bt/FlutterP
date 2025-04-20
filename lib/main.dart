import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/carrito_provider.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/compra_page.dart';
import 'screens/carrito_page.dart';
import 'screens/perfil_page.dart';
import 'screens/facturas_page.dart';
import 'provider/user_provider.dart'; 
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';



// 🔔 Notificaciones locales
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configuración de Stripe
  Stripe.publishableKey = 'pk_test_51QIewwDhm58X9ebvL2b9ZGx2AxItSBgRuWMyPxDu88d4rV5fI8XDJUe43PVGcLvOwNIWtTYBcEZM8J4nl9JDiESg005uydqNOc';
  await Stripe.instance.applySettings().catchError((error) {
    print('⚠️ Error al configurar Stripe: $error');
  });

   // Inicializar notificaciones locales
  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

   const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);
  await Permission.notification.request();



  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login App',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/perfil': (context) => const PerfilPage(),
        '/compra': (context) => const CompraPage(),
        '/carrito': (context) => const CarritoPage(),
        '/facturas': (context) => const FacturasPage(),
      },
    );
  }
}