import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../extra_screens/completed_tasks_screen.dart';
import '../extra_screens/personal_info_screen.dart';
import '../extra_screens/help_support_screen.dart';







class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName ?? "User";
    final email = user?.email ?? "No email";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFFFFE97A),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),

          // ✅ Profile Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 46,
                  backgroundColor: const Color(0xFFFFE97A),
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // ✅ Settings Section
          _tile(
            icon: Icons.task_alt,
            text: "Completed Tasks",
            onTap: () {Navigator.push(
      context,
      MaterialPageRoute(builder: (_) =>   CompletedTaskScreen()),
    );
  },
          ),

          _tile(
            icon: Icons.person_outline,
            text: "personal Information",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PersonalInfoScreen()),
              );
            },
          ),
_tile(
  icon: Icons.help_outline,
  text: "Help & Support",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
    );
  },
),

          const Spacer(),

          // ✅ Logout Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Logout",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  // ✅ go back to login screen
                  Navigator.of(context).pushNamedAndRemoveUntil(
  '/login',
  (route) => false,
);

                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // reusable tile
  Widget _tile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
