import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationOffset {
  final String id;
  final int amount;
  final String unit; // 'minutes', 'hours', 'days', 'weeks'

  NotificationOffset({
    required this.id,
    required this.amount,
    required this.unit,
  });

  factory NotificationOffset.fromMap(Map<String, dynamic> map) {
    return NotificationOffset(
      id: map['id'] as String,
      amount: (map['amount'] as num).toInt(),
      unit: map['unit'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'unit': unit,
    };
  }

  String get label {
    switch (unit) {
      case 'minutes':
        return '$amount ${amount == 1 ? 'minuto' : 'minutos'} antes';
      case 'hours':
        return '$amount ${amount == 1 ? 'hora' : 'horas'} antes';
      case 'days':
        return '$amount ${amount == 1 ? 'día' : 'días'} antes';
      case 'weeks':
        return '$amount ${amount == 1 ? 'semana' : 'semanas'} antes';
      default:
        return '$amount $unit antes';
    }
  }

  Duration get duration {
    switch (unit) {
      case 'minutes':
        return Duration(minutes: amount);
      case 'hours':
        return Duration(hours: amount);
      case 'days':
        return Duration(days: amount);
      case 'weeks':
        return Duration(days: amount * 7);
      default:
        return Duration(minutes: amount);
    }
  }
}

class TaskModel {
  final String? id;
  final String title;
  final String description;
  final String location;
  final String date; // YYYY-MM-DD
  final String time; // HH:MM or empty for all-day
  final String color; // hex color
  final bool isCompleted;
  final List<NotificationOffset> notifications;
  final DateTime createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.description = '',
    this.location = '',
    required this.date,
    this.time = '',
    this.color = '#ffffff',
    this.isCompleted = false,
    this.notifications = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  DateTime get dateTime {
    if (time.isEmpty) {
      return DateTime.parse('${date}T00:00:00');
    }
    return DateTime.parse('${date}T$time:00');
  }

  bool get isPast {
    return dateTime.isBefore(DateTime.now()) || isCompleted;
  }

  factory TaskModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? '',
      date: data['date'] as String? ?? '',
      time: data['time'] as String? ?? '',
      color: data['color'] as String? ?? '#ffffff',
      isCompleted: data['isCompleted'] as bool? ?? false,
      notifications: (data['notifications'] as List<dynamic>? ?? [])
          .map((n) => NotificationOffset.fromMap(n as Map<String, dynamic>))
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': date,
      'time': time,
      'color': color,
      'isCompleted': isCompleted,
      'notifications': notifications.map((n) => n.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? date,
    String? time,
    String? color,
    bool? isCompleted,
    List<NotificationOffset>? notifications,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      date: date ?? this.date,
      time: time ?? this.time,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      notifications: notifications ?? this.notifications,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
