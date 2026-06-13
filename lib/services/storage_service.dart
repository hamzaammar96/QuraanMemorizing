import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/plan_settings.dart';
import '../models/progress_state.dart';

/// خدمة التخزين المحلي على الجهاز باستخدام SharedPreferences.
/// تحفظ الإعدادات والتقدم بصيغة JSON.
class StorageService {
  static const _settingsKey = 'mutqin_settings';
  static const _progressKey = 'mutqin_progress';

  Future<void> saveSettings(PlanSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<PlanSettings?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return null;
    return PlanSettings.fromJson(
        (jsonDecode(raw) as Map).cast<String, dynamic>());
  }

  Future<void> saveProgress(ProgressState progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressKey, jsonEncode(progress.toJson()));
  }

  Future<ProgressState> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null) return ProgressState.initial();
    return ProgressState.fromJson(
        (jsonDecode(raw) as Map).cast<String, dynamic>());
  }
}
