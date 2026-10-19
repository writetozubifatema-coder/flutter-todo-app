import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:to_do_app/extra_screens/all_task_screen.dart';
import 'package:to_do_app/extra_screens/calendar_screen.dart';
import 'package:to_do_app/screens/profile_screen.dart' show ProfileScreen;
import 'package:to_do_app/screens/settings_screen.dart';
import '../services/task_service.dart';
import 'task_screen.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final String name = user?.displayName ?? "User";
    final String email = user?.email ?? "No email";
    final TaskService taskService = TaskService();


    final List<Map<String, dynamic>> categories = [
      {
        "title": "Today",
        "tasks": 4,
        "icon": Icons.wb_sunny_outlined,
      },
      {
        "title": "Planned",
        "tasks": 2,
        "icon": Icons.calendar_month_outlined,
      },
      {
        "title": "Personal",
        "tasks": 6,
        "icon": Icons.person_outline,
      },
      {
        "title": "Work",
        "tasks": 5,
        "icon": Icons.work_outline,
      },
      {
        "title": "Shopping",
        "tasks": 8,
        "icon": Icons.shopping_bag_outlined,
      },
      {
        "title": "Medicines",
        "tasks": 8,
        "icon": Icons.medical_services_outlined,
      },
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context, name, email),
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Top Yellow Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE97A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menu icon
                  Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Builder(
  builder: (context) => IconButton(
    icon: const Icon(Icons.menu),
   onPressed: () => Scaffold.of(context).openDrawer(),
  ),
),



                  ),

                  const SizedBox(width: 12),

                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello $name",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StreamBuilder<int>(
  stream: taskService.totalPendingTasksCountStream(),
  builder: (context, snapshot) {
    final total = snapshot.data ?? 0;
    return Text(
      "Today you have $total tasks",
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black54,
      ),
    );
  },
),

                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile Icon
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "U",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Category List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];

                  return Padding(
  padding: const EdgeInsets.only(bottom: 14),
  child: StreamBuilder<int>(
    stream: taskService.pendingTaskCountStream(item["title"]),
    builder: (context, snapshot) {
      final count = snapshot.data ?? 0;

      return _categoryCard(
        title: item["title"],
        tasks: count,
        icon: item["icon"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskScreen(title: item["title"]),
            ),
          );
        },
      );
    },
  ),
);

                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard({
    required String title,
    required int tasks,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  curve: Curves.easeOut,
  child: Container(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          
          boxShadow: [
            BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
            ),
          ],
        ),
        
          child: Row(
            children: [
              // Icon circle
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3C7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.black87),
              ),
        
              const SizedBox(width: 14),
        
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$tasks Tasks",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
        
              // Three dots
              const Icon(Icons.more_vert, color: Colors.black45),
            ],
          ),
        ),
  ),
      ),
    );
  }Widget _buildDrawer(BuildContext context, String name, String email) {
  return Drawer(
    child: Column(
      children: [
        // Header
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(
            color: Color(0xFFFFE97A),
          ),
          accountName: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          accountEmail: Text(
            email,
            style: const TextStyle(color: Colors.black54),
          ),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "U",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Drawer Items
        ListTile(
          leading: const Icon(Icons.list_alt),
          title: const Text("All Tasks"),
          onTap: () {
           Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const AllTasksScreen()),
);

          },
        ),
        ListTile(
  leading: const Icon(Icons.person),
  title: const Text("Profile"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  },
),
ListTile(
  leading: const Icon(Icons.calendar_month),
  title: const Text("Calendar"),
  onTap: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CalendarScreen(),
      ),
    );
  },
),




      ListTile(
        leading: const Icon(Icons.settings),
        title: const Text("Settings"),
        onTap: () {
          Navigator.pop(context); // close drawer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SettingsScreen(),
            ),
          );
        },
      ),

        const Spacer(),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text("Logout"),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

}
