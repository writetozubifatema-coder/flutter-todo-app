import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getCompletedTasks() {
  return _taskCollection

      
      .where("isDone", isEqualTo: true)
      .snapshots();
}


String? get uid => FirebaseAuth.instance.currentUser?.uid;
                                                  

  CollectionReference<Map<String, dynamic>> get _taskCollection {
  final userId = uid;
  if (userId == null) {
    throw Exception("User not logged in");
  }
  return _db.collection("users").doc(userId).collection("tasks");
}


      Future<void> updateTask({
  required String docId,
  required String title,
  required String description,
  required String priority,
  DateTime? dueDate,
}) async {
  await _taskCollection.doc(docId).update({
    "title": title.trim(),
    "description": description.trim(),
    "priority": priority,
    "dueDate": dueDate == null ? null : Timestamp.fromDate(dueDate),
  });
}


  // ✅ Add Task
  Future<void> addTask({
  required String title,
  required String category,
  String description = "",
  String priority = "Low",
  bool hasDueDate = false,
  DateTime? dueDate,
}) async {
  await _taskCollection.add({
    "title": title.trim(),
    "description": description.trim(),
    "category": category,
    "priority": priority,
    "dueDate": dueDate == null ? null : Timestamp.fromDate(dueDate),
    "hasDueDate": hasDueDate,
    "isDone": false,
    "createdAt": FieldValue.serverTimestamp(),
  });
}

Stream<QuerySnapshot<Map<String, dynamic>>> getAllPendingTasksStream() {
  return _taskCollection
      .where("isDone", isEqualTo: false)
      .orderBy("dueDate", descending: false)
      .snapshots();
}



  // ✅ Get tasks stream (by category)
 Stream<QuerySnapshot<Map<String, dynamic>>> getTasksByCategory(
  String category,
) {
  return _taskCollection
      .where("category", isEqualTo: category)
      .where("isDone", isEqualTo: false) // 👈 KEY LINE
      .snapshots();
}



  // ✅ Update done status
  Future<void> toggleDone(String docId, bool newValue) async {
    await _taskCollection.doc(docId).update({
      "isDone": newValue,
    });
  }

  // ✅ Delete task
  Future<void> deleteTask(String docId) async {
    await _taskCollection.doc(docId).delete();
  }

  // ✅ Stream count for each category
 // ✅ Pending task count per category
Stream<int> pendingTaskCountStream(String category) {
  return _taskCollection
      .where("category", isEqualTo: category)
      .where("isDone", isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}

// ✅ Total pending tasks (for header)
Stream<int> totalPendingTasksCountStream() {
  return _taskCollection
      .where("isDone", isEqualTo: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.length);
}
Stream<QuerySnapshot<Map<String, dynamic>>> tasksForDateStream(
  DateTime date,
) {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));

  return _taskCollection
      .where("isDone", isEqualTo: false)
      .where("dueDate", isGreaterThanOrEqualTo: start)
      .where("dueDate", isLessThan: end)
      .orderBy("dueDate")
      .snapshots();
}


}
