import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final androidResult = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return result ?? androidResult ?? false;
  }

  Future<void> scheduleTaskNotifications(TaskModel task) async {
    if (task.id == null || task.time.isEmpty) return;

    for (final offset in task.notifications) {
      final taskDateTime = task.dateTime;
      final fireTime = taskDateTime.subtract(offset.duration);

      if (fireTime.isBefore(DateTime.now())) continue;

      final notifId = _generateId(task.id!, offset.id);

      await _plugin.zonedSchedule(
        notifId,
        'Next Thing',
        '${task.title} — ${offset.label}',
        tz.TZDateTime.from(fireTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'nextthing_reminders',
            'Recordatorios',
            channelDescription: 'Notificaciones de recordatorio de eventos',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelTaskNotifications(TaskModel task) async {
    if (task.id == null) return;
    for (final offset in task.notifications) {
      final notifId = _generateId(task.id!, offset.id);
      await _plugin.cancel(notifId);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> rescheduleAll(List<TaskModel> tasks) async {
    await cancelAll();
    for (final task in tasks) {
      if (!task.isCompleted) {
        await scheduleTaskNotifications(task);
      }
    }
  }

  int _generateId(String taskId, String offsetId) {
    return (taskId + offsetId).hashCode.abs() % 2147483647;
  }
}
