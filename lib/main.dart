import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:timezone/data/latest.dart' as tz show initializeTimeZones;
import 'package:timezone/standalone.dart' as tz show setLocalLocation;

import 'package:timezone/timezone.dart' as tz show getLocation;
import 'package:to_do_app/services/auth_gate.dart';
import 'package:to_do_app/services/notification_service.dart';
import 'firebase_options.dart';
import 'services/app_theme.dart' show AppTheme;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
await NotificationService.init();

  

 tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
final prefs = await SharedPreferences.getInstance();
final isDark = prefs.getBool('darkMode') ?? false;
AppTheme.themeMode.value =
    isDark ? ThemeMode.dark : ThemeMode.light;

  
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (_, themeMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          
          home: AuthGate(),
        );
      },
    );
  }
}
