import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// 🔔 Make sure this is declared somewhere globally
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "If you are facing any issue:\n\n"
              "• Restart the app\n"
              "• Check internet connection\n"
              "• Update to latest version\n\n"
              "Still stuck?\n"
              "Contact support: support@talktoammarbaig@gmail.com",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),


  

          ],
        ),
      ),
    );
  }
}
