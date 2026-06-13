import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/plan_settings.dart';

/// خدمة الإشعارات اليومية المجدولة (إشعار للمراجعة وإشعار للحفظ).
/// النصوص عربية بالكامل. الإشعارات غير مدعومة على الويب (تُتجاهل بأمان).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const int _reviewNotifId = 1001;
  static const int _memorizeNotifId = 1002;

  bool _initialized = false;

  /// تهيئة الخدمة وقواعد المناطق الزمنية.
  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// طلب أذونات الإشعارات (أندرويد 13+ و iOS).
  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// إعادة جدولة الإشعارات بناءً على الإعدادات الحالية.
  Future<void> reschedule(PlanSettings settings) async {
    if (kIsWeb) return;
    await init();
    // إلغاء الإشعارات القديمة أولاً.
    await _plugin.cancel(_reviewNotifId);
    await _plugin.cancel(_memorizeNotifId);

    if (!settings.notificationsEnabled) return;

    await requestPermissions();

    await _scheduleDaily(
      id: _reviewNotifId,
      hour: settings.reviewNotifHour,
      minute: settings.reviewNotifMinute,
      title: 'مُتقِن يذكّرك بوردك اليومي',
      body: 'حان وقت مراجعة القرآن اليوم',
    );

    await _scheduleDaily(
      id: _memorizeNotifId,
      hour: settings.memorizeNotifHour,
      minute: settings.memorizeNotifMinute,
      title: 'وردك اليوم بانتظارك',
      body: 'لا تنس ورد الحفظ اليومي',
    );
  }

  /// جدولة إشعار يومي متكرر في وقت محدد.
  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'mutqin_daily',
      'تذكير الورد اليومي',
      channelDescription: 'إشعارات تذكير المراجعة والحفظ اليومي',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOf(hour, minute),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // تكرار يومي
    );
  }

  /// حساب أقرب موعد قادم للوقت المحدد.
  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }
}
