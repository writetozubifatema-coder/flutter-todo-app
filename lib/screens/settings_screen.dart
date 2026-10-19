import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

 Future<void> _loadSettings() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _notificationsEnabled =
        prefs.getBool('notificationsEnabled') ?? true;
  });
}

Future<void> _toggleNotifications(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('notificationsEnabled', value);

  setState(() {
    _notificationsEnabled = value;
  });

  if (!value) {
    await NotificationService().cancelAll();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFFFFE97A),
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          /// 🔔 NOTIFICATION TOGGLE
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active),
            title: const Text(
              "Task Notifications",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text("Remind me about my tasks"),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
          ),

          const Divider(),

          /// 🌟 EXTRA FEATURE (MY IDEA)
          ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text(
              "Daily Productivity Tip",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text("Tap to get a quick focus tip"),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text("💡 Productivity Tip"),
                  content: const Text(
                    "Write down your 3 most important tasks for tomorrow "
                    "before sleeping. It reduces stress and increases focus.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Got it"),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),

          /// ℹ️ ABOUT SECTION
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              "App Version",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text("1.0.0"),
          ),

          const SizedBox(height: 20),

          /// ❤️ FOOTER (CUTE TOUCH)
          const Center(
            child: Text(
              "Made with 💛 by Zubi",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
