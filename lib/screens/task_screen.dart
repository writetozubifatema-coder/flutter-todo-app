import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';

class TaskScreen extends StatefulWidget {
  final String title; // category name

  const TaskScreen({super.key, required this.title});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
  
}

class _TaskScreenState extends State<TaskScreen> {
  final TaskService _taskService = TaskService();

  String? _animatingTaskId;

  final NotificationService _notificationService = NotificationService();
  final Map<String, bool> _localDoneState = {};
  String _searchQuery = "";
  bool _isSavingTask = false;
 

  // ✅ ADD THIS

  String _formatDueText(DateTime? due) {
    if (due == null) return "No due date";

    final now = DateTime.now();
    final diff = due.difference(now);

    if (diff.inSeconds <= 0) {
      final overdue = now.difference(due);
      if (overdue.inMinutes < 60) return "Overdue by ${overdue.inMinutes} min";
      if (overdue.inHours < 24) return "Overdue by ${overdue.inHours} hrs";
      return "Overdue by ${overdue.inDays} days";
    }

    if (diff.inMinutes < 60) return "Due in ${diff.inMinutes} min";
    if (diff.inHours < 24) return "Due in ${diff.inHours} hrs";
    if (diff.inDays == 1) return "Due tomorrow";
    return "Due in ${diff.inDays} days";
  }

  void _showEditTaskBottomSheet({
    required String docId,
    required String oldTitle,
    required String oldDescription,
    required String oldPriority,
    DateTime? oldDueDate,
  }) {
    final TextEditingController titleController = TextEditingController(
      text: oldTitle,
    );
    final TextEditingController descController = TextEditingController(
      text: oldDescription,
    );

    String selectedPriority = oldPriority;
    DateTime? selectedDateTime = oldDueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: SizedBox(width: 40, child: Divider(thickness: 4)),
                    ),
                    const SizedBox(height: 12),

                    const Text(
                      "Edit Task",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Task Title",
                        filled: true,
                        fillColor: const Color(0xFFF6F6F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Description (optional)",
                        filled: true,
                        fillColor: const Color(0xFFF6F6F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Priority dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPriority,
                          isExpanded: true,
                          items: ["Low", "Medium", "High"]
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text("Priority: $p"),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setSheetState(() => selectedPriority = val);
                          },
                        ),
                      ),
                    
                    ),
                    const SizedBox(height: 12),
                    

// ✅ EDIT DUE DATE & TIME BUTTON
SizedBox(
  width: double.infinity,
  height: 50,
  child: OutlinedButton(
    onPressed: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: selectedDateTime ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (date == null) return;

      final time = await showTimePicker(
        context: context,
        initialTime: selectedDateTime != null
            ? TimeOfDay.fromDateTime(selectedDateTime!)
            : TimeOfDay.now(),
      );

      if (time == null) return;

      setSheetState(() {
        selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    },
    child: Text(
      selectedDateTime == null
          ? "Edit Due Date & Time"
          : "Due: ${selectedDateTime!.day}/${selectedDateTime!.month} "
            "${selectedDateTime!.hour}:${selectedDateTime!.minute.toString().padLeft(2, '0')}",
    ),
  ),
  
),
const SizedBox(height: 16),



                    

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2CC7B8),
    foregroundColor: Colors.white,
    disabledBackgroundColor: const Color(0xFF2CC7B8),
    disabledForegroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  ),
  onPressed: () async {
    if (titleController.text.trim().isEmpty) return;

    await _taskService.updateTask(
  docId: docId,
  title: titleController.text.trim(),
  description: descController.text,
  priority: selectedPriority,
  dueDate: selectedDateTime,
);



    Navigator.pop(context);
  },
  child: const Text(
    "Save Task",
    style: TextStyle(
      fontWeight: FontWeight.w800,
    ),
  ),
),


),

                  

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChip({
    required String text,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),

      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: color),
          if (icon != null) const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////////
  void _showAddTaskBottomSheet() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    final rootContext = context;

    String selectedPriority = "Low";
    DateTime? selectedDateTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: SizedBox(width: 40, child: Divider(thickness: 4)),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Add Task (${widget.title})",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Title
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "Task Title",
                        filled: true,
                        fillColor: const Color(0xFFF6F6F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Description
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Description (optional)",
                        filled: true,
                        fillColor: const Color(0xFFF6F6F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Priority dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F6F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPriority,
                          isExpanded: true,
                          items: ["Low", "Medium", "High"]
                              .map(
                                (p) => DropdownMenuItem(
                                  value: p,
                                  child: Text("Priority: $p"),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setSheetState(() => selectedPriority = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

// ✅ EDIT DUE DATE & TIME BUTTON
SizedBox(
  width: double.infinity,
  height: 50,
  child: OutlinedButton(
    onPressed: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: selectedDateTime ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );

      if (date == null) return;

      final time = await showTimePicker(
        context: context,
        initialTime: selectedDateTime != null
            ? TimeOfDay.fromDateTime(selectedDateTime!)
            : TimeOfDay.now(),
      );

      if (time == null) return;

      setSheetState(() {
        selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    },
    child: Text(
      selectedDateTime == null
          ? "Edit Due Date & Time"
          : "Due: ${selectedDateTime!.day}/${selectedDateTime!.month} "
            "${selectedDateTime!.hour}:${selectedDateTime!.minute.toString().padLeft(2, '0')}",
    ),
  ),
),
const SizedBox(height: 16),

                 SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
   onPressed: () async {
  print("ADD SAVE TASK CLICKED");

  try {
    print("STEP 1: calling addTask");

   await _taskService.addTask(
  title: titleController.text.trim(),
  description: descController.text,
  priority: selectedPriority,
  category: widget.title,
  dueDate: selectedDateTime,
);






    print("STEP 2: task added");

    await _notificationService.showTaskSavedNotification(
      taskName: titleController.text.trim(),
      selectedDateTime: selectedDateTime,
    );

    print("STEP 3: notification shown");

    Navigator.pop(context);
    print("STEP 4: bottom sheet closed");
  } catch (e, s) {
    print("❌ ERROR IN SAVE TASK");
    print(e);
    print(s);
  }
  
},


    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2CC7B8), // ✅ GREEN FIX
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    ),
    child: const Text(
      "Save Task",
      style: TextStyle(
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    ),
  ),
),


                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2CC7B8),
        onPressed: _showAddTaskBottomSheet,

        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // ✅ Curved top header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE97A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.toLowerCase());
                },
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  const Icon(Icons.checklist, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ✅ Live Firestore Tasks
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _taskService.getTasksByCategory(widget.title),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Center(
                        key: const ValueKey("empty_state"),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Colors.black26,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "You're all caught up ✨",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Add a task to stay productive",
                              style: TextStyle(color: Colors.black38),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();

                      final String taskTitle = data["title"] ?? "";
                      if (_searchQuery.isNotEmpty &&
                          !taskTitle.toLowerCase().contains(_searchQuery)) {
                        return const SizedBox.shrink();
                      }

                      final bool isDone = _localDoneState[doc.id] ?? false;

                      final String description = data["description"] ?? "";
                      final String priority = data["priority"] ?? "Low";
                      final Timestamp? dueTs = data["dueDate"];
                      final DateTime? dueDate = dueTs?.toDate();
                      final bool hasDueDate = data["hasDueDate"] ?? false;
                      final bool isOverdue =
                          hasDueDate && dueDate != null && dueDate.isBefore(DateTime.now());



                      return AnimatedSlide(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        offset: const Offset(0, 0),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: 1,
                          child: Dismissible(
                            key: ValueKey(doc.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) async {
                              await _taskService.deleteTask(doc.id);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? Colors.red.withOpacity(0.04)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isOverdue
                                    ? Border.all(
                                        color: Colors.red.shade300,
                                        width: 1.3,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Opacity(
                                opacity: isDone ? 0.6 : 1,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 10),

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
                                      // ✅ PRIORITY COLOR STRIP
                                      SizedBox(
                                        width: 6,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: priority == "High"
                                                ? Colors.red
                                                : priority == "Medium"
                                                ? Colors.orange
                                                : Colors.green,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  bottomLeft: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),

                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // ✅ CHECKBOX
                                              AnimatedScale(
                                                scale:
                                                    _animatingTaskId == doc.id
                                                    ? 1.3
                                                    : 1.0,
                                                duration: const Duration(
                                                  milliseconds: 300,
                                                ),
                                                curve: Curves.easeOutBack,
                                                child: AnimatedOpacity(
                                                  opacity:
                                                      _animatingTaskId == doc.id
                                                      ? 1
                                                      : 0.9,
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  
                                                  child: Checkbox(
                                                    value:
                                                        _localDoneState[doc
                                                            .id] ??
                                                        false,
                                                    activeColor: Colors.green,
                                                    onChanged: (val) {
                                                      if (val == null) return;

                                                      // 1️⃣ Update local UI state FIRST
                                                      setState(() {
                                                        _localDoneState[doc
                                                                .id] =
                                                            true;
                                                        _animatingTaskId =
                                                            doc.id;
                                                      });

                                                      // 2️⃣ Let animation play
                                                      Future.delayed(
                                                        const Duration(
                                                          milliseconds: 700,
                                                        ),
                                                        () async {
                                                          if (!mounted) return;

                                                          // 3️⃣ Now update Firestore
                                                          await _taskService
                                                              .toggleDone(
                                                                doc.id,
                                                                true,
                                                              );

                                                          // 4️⃣ Remove task
                                                          


                                                          if (!mounted) return;
                                                          setState(() {
                                                            _animatingTaskId =
                                                                null;
                                                            _localDoneState
                                                                .remove(doc.id);
                                                          });
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(width: 4),

                                              // ✅ TASK CONTENT
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // TITLE
                                                    Text(
                                                      taskTitle,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        decoration: isDone
                                                            ? TextDecoration
                                                                  .lineThrough
                                                            : TextDecoration
                                                                  .none,
                                                        color: isDone
                                                            ? Colors.black38
                                                            : Colors.black,
                                                      ),
                                                    ),

                                                    if (description
                                                        .trim()
                                                        .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 4,
                                                            ),
                                                        child: Text(
                                                          description,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: isDone
                                                                ? Colors.black26
                                                                : Colors
                                                                      .black54,
                                                          ),
                                                        ),
                                                      ),

                                                    const SizedBox(height: 6),

                                                    // PRIORITY + DUE DATE ROW
                                                    Wrap(
  spacing: 8,
  children: [
    _buildChip(
      text: priority,
      color: priority == "High"
          ? Colors.red
          : priority == "Medium"
              ? Colors.orange
              : Colors.green,
    ),
    if (dueDate != null)
      _buildChip(
        text: _formatDueText(dueDate),
        color: _formatDueText(dueDate).startsWith("Overdue")
            ? Colors.red
            : Colors.blue,
        icon: Icons.access_time,
      ),
  ],
),

                                                    
                                                  ],
                                                ),
                                              ),

                                              // MENU
                                              PopupMenuButton<String>(
                                                onSelected: (value) {
                                                  if (value == "edit") {
                                                    _showEditTaskBottomSheet(
                                                      docId: doc.id,
                                                      oldTitle: taskTitle,
                                                      oldDescription:
                                                          description,
                                                      oldPriority: priority,
                                                      oldDueDate:
                                                          dueDate ??
                                                          DateTime(
                                                            DateTime.now().year,
                                                            DateTime.now()
                                                                .month,
                                                            DateTime.now().day,
                                                          ),
                                                    );
                                                  } else if (value ==
                                                      "delete") {
                                                    _taskService.deleteTask(
                                                      doc.id,
                                                    );
                                                  }
                                                },
                                                itemBuilder: (context) =>
                                                    const [
                                                      PopupMenuItem(
                                                        value: "edit",
                                                        child: Text("Edit"),
                                                      ),
                                                      PopupMenuItem(
                                                        value: "delete",
                                                        child: Text("Delete"),
                                                      ),
                                                    ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
