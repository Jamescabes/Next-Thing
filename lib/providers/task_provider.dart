import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../demo_config.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService? _firestore;
  final NotificationService _notifService = NotificationService();

  TaskProvider() : _firestore = kDemoMode ? null : FirestoreService();

  List<TaskModel> _allTasks = [];
  StreamSubscription<List<TaskModel>>? _subscription;
  bool _isLoading = false;
  String? _uid;
  bool _initialized = false;
  int _pastLimit = 10;

  List<TaskModel> get allTasks => _allTasks;
  bool get isLoading => _isLoading;
  bool get isInitialized => _initialized;

  List<TaskModel> get futureTasks {
    final now = DateTime.now();
    return _allTasks
        .where((t) => !t.isCompleted && t.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<TaskModel> get pastTasks {
    final now = DateTime.now();
    final past = _allTasks
        .where((t) => t.isCompleted || t.dateTime.isBefore(now))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return past.take(_pastLimit).toList();
  }

  int get totalPastCount {
    final now = DateTime.now();
    return _allTasks
        .where((t) => t.isCompleted || t.dateTime.isBefore(now))
        .length;
  }

  bool get hasMorePast => totalPastCount > _pastLimit;

  void loadMorePast() {
    _pastLimit += 30;
    notifyListeners();
  }

  void init(String uid) {
    if (_initialized && _uid == uid) return;
    _uid = uid;
    _initialized = true;

    if (kDemoMode) {
      _allTasks = _buildDemoTasks();
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();
    _subscription?.cancel();
    _subscription = _firestore!.tasksStream(uid).listen((tasks) {
      _allTasks = tasks;
      _isLoading = false;
      notifyListeners();
      _notifService.rescheduleAll(tasks);
    });
  }

  List<TaskModel> _buildDemoTasks() {
    final now = DateTime.now();
    String d(int offsetDays, [String time = '']) {
      final dt = now.add(Duration(days: offsetDays));
      final dateStr =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      return dateStr;
    }

    return [
      TaskModel(
        id: 'demo-1',
        title: 'Revisión de diseño UI',
        description: 'Feedback del equipo sobre los nuevos componentes',
        date: d(-5),
        time: '10:00',
        color: '#E0F2F1',
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      TaskModel(
        id: 'demo-2',
        title: 'Llamada con el cliente',
        description: 'Presentación del avance del sprint',
        date: d(-3),
        time: '15:30',
        color: '#E3F2FD',
        isCompleted: true,
        createdAt: now.subtract(const Duration(days: 4)),
      ),
      TaskModel(
        id: 'demo-3',
        title: 'Reunión de equipo',
        description: '',
        date: d(-1),
        time: '11:00',
        color: '#FFF9C4',
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      TaskModel(
        id: 'demo-4',
        title: 'Sprint planning',
        description: 'Planificar las tareas del próximo sprint con el equipo',
        location: 'Sala de reuniones B',
        date: d(1),
        time: '09:00',
        color: '#E0F2F1',
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: 'demo-5',
        title: 'Demo con el cliente',
        description: 'Presentación final de la fase 1',
        date: d(3),
        time: '16:00',
        color: '#FFCDD2',
        isCompleted: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: 'demo-6',
        title: 'Dentista',
        description: '',
        location: 'Clínica Dr. Martínez',
        date: d(7),
        time: '12:30',
        color: '#F8BBD0',
        isCompleted: false,
        createdAt: now,
      ),
      TaskModel(
        id: 'demo-7',
        title: 'Viaje a Barcelona',
        description: 'Conferencia anual de tecnología',
        date: d(12),
        time: '',
        color: '#E3F2FD',
        isCompleted: false,
        createdAt: now,
      ),
      TaskModel(
        id: 'demo-8',
        title: 'Revisión Q2',
        description: 'Resultados y objetivos del segundo trimestre',
        date: d(20),
        time: '10:00',
        color: '#FFF9C4',
        isCompleted: false,
        createdAt: now,
      ),
    ];
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> addTask(TaskModel task) async {
    if (_uid == null) return;
    final coloredTask = task.color.isEmpty
        ? task.copyWith(color: _randomColor())
        : task;
    if (kDemoMode) {
      final withId = coloredTask.copyWith(
          id: 'demo-${DateTime.now().millisecondsSinceEpoch}');
      _allTasks = [..._allTasks, withId];
      notifyListeners();
      return;
    }
    await _firestore!.addTask(_uid!, coloredTask);
  }

  Future<void> updateTask(TaskModel task) async {
    if (_uid == null) return;
    if (kDemoMode) {
      _allTasks = [
        for (final t in _allTasks) t.id == task.id ? task : t,
      ];
      notifyListeners();
      return;
    }
    await _firestore!.updateTask(_uid!, task);
  }

  Future<void> deleteTask(String taskId) async {
    if (_uid == null) return;
    if (kDemoMode) {
      _allTasks = _allTasks.where((t) => t.id != taskId).toList();
      notifyListeners();
      return;
    }
    final task = _allTasks.firstWhere(
      (t) => t.id == taskId,
      orElse: () => TaskModel(title: '', date: ''),
    );
    await _notifService.cancelTaskNotifications(task);
    await _firestore!.deleteTask(_uid!, taskId);
  }

  Future<void> toggleComplete(TaskModel task) async {
    if (_uid == null) return;
    if (kDemoMode) {
      await updateTask(task.copyWith(isCompleted: !task.isCompleted));
      return;
    }
    await _firestore!.toggleComplete(_uid!, task);
  }

  void reset() {
    _subscription?.cancel();
    _subscription = null;
    _allTasks = [];
    _uid = null;
    _initialized = false;
    _pastLimit = 10;
    notifyListeners();
  }

  String _randomColor() {
    final pool = AppColorPresets.randomPool;
    return pool[Random().nextInt(pool.length)];
  }
}
