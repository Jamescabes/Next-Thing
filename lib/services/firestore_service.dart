import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _tasksCollection(String uid) {
    return _db.collection('users').doc(uid).collection('tasks');
  }

  Stream<List<TaskModel>> tasksStream(String uid) {
    return _tasksCollection(uid)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addTask(String uid, TaskModel task) async {
    await _tasksCollection(uid).add(task.toFirestore());
  }

  Future<void> updateTask(String uid, TaskModel task) async {
    if (task.id == null) return;
    await _tasksCollection(uid).doc(task.id).update(task.toFirestore());
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _tasksCollection(uid).doc(taskId).delete();
  }

  Future<void> toggleComplete(String uid, TaskModel task) async {
    if (task.id == null) return;
    await _tasksCollection(uid).doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  Future<void> deleteAllUserData(String uid) async {
    final batch = _db.batch();
    final tasks = await _tasksCollection(uid).get();
    for (final doc in tasks.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    await _db.collection('users').doc(uid).delete();
  }
}
