import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/task_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final TaskService _taskService = TaskService();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Calendar"),
        backgroundColor: const Color(0xFFFFE97A),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// 📅 CALENDAR
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.orange.shade200,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              selectedTextStyle:
                  const TextStyle(color: Colors.white),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 10),

          /// 🧾 TASKS FOR SELECTED DAY
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _taskService.tasksForDateStream(_selectedDay),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No tasks for this day ✨",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final String title = data['title'];
                    final String priority =
                        data['priority'] ?? "Low";
                    final Timestamp ts = data['dueDate'];
                    final DateTime due = ts.toDate();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          /// Priority strip
                          Container(
                            width: 6,
                            height: 46,
                            decoration: BoxDecoration(
                              color: priority == "High"
                                  ? Colors.red
                                  : priority == "Medium"
                                      ? Colors.orange
                                      : Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                               if (!(due.hour == 0 && due.minute == 0))
  Text(
    "⏰ ${due.hour}:${due.minute.toString().padLeft(2, '0')}",
    style: const TextStyle(color: Colors.black54),
  ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
