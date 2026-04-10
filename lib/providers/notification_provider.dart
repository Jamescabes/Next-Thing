import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  static const _prefsKey = 'nt_notification_prefs';

  final NotificationService _service = NotificationService();

  bool _enabled = false;
  bool _upcomingEvents = true;
  List<NotificationOffset> _defaultOffsets = [];
  bool _permissionGranted = false;

  bool get enabled => _enabled;
  bool get upcomingEvents => _upcomingEvents;
  List<NotificationOffset> get defaultOffsets => _defaultOffsets;
  bool get permissionGranted => _permissionGranted;

  Future<void> init() async {
    await _service.initialize();
    await _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json != null) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      _enabled = map['enabled'] as bool? ?? false;
      _upcomingEvents = map['upcomingEvents'] as bool? ?? true;
      _defaultOffsets = (map['defaultOffsets'] as List<dynamic>? ?? [])
          .map((n) => NotificationOffset.fromMap(n as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'enabled': _enabled,
        'upcomingEvents': _upcomingEvents,
        'defaultOffsets': _defaultOffsets.map((o) => o.toMap()).toList(),
      }),
    );
  }

  Future<bool> requestPermission() async {
    final granted = await _service.requestPermission();
    _permissionGranted = granted;
    if (granted) {
      _enabled = true;
      await _savePrefs();
      notifyListeners();
    }
    return granted;
  }

  Future<void> toggleEnabled() async {
    if (!_enabled) {
      final granted = await requestPermission();
      if (!granted) return;
    } else {
      _enabled = false;
      await _savePrefs();
      notifyListeners();
    }
  }

  Future<void> setUpcomingEvents(bool value) async {
    _upcomingEvents = value;
    await _savePrefs();
    notifyListeners();
  }

  Future<void> addDefaultOffset(NotificationOffset offset) async {
    _defaultOffsets.add(offset);
    await _savePrefs();
    notifyListeners();
  }

  Future<void> removeDefaultOffset(String id) async {
    _defaultOffsets.removeWhere((o) => o.id == id);
    await _savePrefs();
    notifyListeners();
  }
}
