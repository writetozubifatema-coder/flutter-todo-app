import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/task_service.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskService taskService = TaskService();

    return Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: const Text("All Tasks"),
        backgroundColor: const Color(0xFFFFE97A),
        foregroundColor: Colors.black,
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: taskService.getAllPendingTasksStream(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 64, color: Colors.black26),
                 
                  Text(
                    "No tasks yet ✨",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              final title = data["title"] ?? "";
              final description = data["description"] ?? "";
              final category = data["category"] ?? "General";
              final priority = data["priority"] ?? "Low";

              return Container(
             
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _priorityChip(priority),
                      ],
                    ),

                    if (description.isNotEmpty) ...[
                     
                      Text(
                        description,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],


                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _priorityChip(String priority) {
    Color color;

    switch (priority) {
      case "High":
        color = Colors.red;
        break;
      case "Medium":
        color = Colors.orange;
        break;
      default:
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        priority,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
