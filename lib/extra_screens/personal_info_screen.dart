import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Account Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            _infoTile("Name", user?.displayName ?? "Not set"),
            _infoTile("Email", user?.email ?? "No email"),
            _infoTile("User ID", user?.uid ?? "Unknown"),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
