import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// 🔥 CALL THIS ON APP START (main.dart)
  /// 
  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings =
        InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);

    // 🔴 ANDROID 13+ PERMISSION
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // 🔴 CREATE CHANNEL
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel',
      'Task Reminders',
      description: 'Task reminder notifications',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// ✅ SHOW CONFIRMATION NOTIFICATION
  Future<void> showTaskSavedNotification({
  required String taskName,
  DateTime? selectedDateTime,
}) async {
  // 🔒 CHECK USER PREFERENCE
  final prefs = await SharedPreferences.getInstance();
  final notificationsEnabled =
      prefs.getBool('notificationsEnabled') ?? true;

  // ❌ If user turned OFF notifications → EXIT
  if (!notificationsEnabled) {
    return;
  }

  String title;
  String body;

  if (selectedDateTime != null) {
    title = 'Task scheduled';
    body = '$taskName at ${_formatDateTime(selectedDateTime)}';
  } else {
    title = 'Task saved';
    body = taskName;
  }

  await _notifications.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    ),
  );
}

  /// OPTIONAL
   Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${_formatTime(dateTime)}';
  }

  String _formatTime(DateTime dateTime) {
    final hour =
        dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute $period';
  }
}
