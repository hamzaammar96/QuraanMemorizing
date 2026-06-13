import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../logic/memorization_planner.dart';
import '../logic/review_planner.dart';
import '../models/achievement_record.dart';
import '../models/day_type.dart';
import '../models/memorization_range.dart';
import '../models/plan_settings.dart';
import '../models/progress_state.dart';
import '../models/ward.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

/// الحالة المركزية للتطبيق.
/// تربط منطق الخطة (المراجعة والحفظ) بالتخزين والإشعارات والواجهة.
class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();

  late PlanSettings settings;
  late ProgressState progress;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool get onboardingDone => _loaded && progress.onboardingDone;

  /// تاريخ اليوم بصيغة yyyy-MM-dd.
  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// تحميل الإعدادات والتقدم من التخزين عند بدء التطبيق.
  Future<void> load() async {
    final savedSettings = await _storage.loadSettings();
    settings = savedSettings ?? PlanSettings.defaults();
    progress = await _storage.loadProgress();
    _loaded = true;
    await _notifications.init();
    notifyListeners();
  }

  // ===== الإعداد الأول =====

  /// إنهاء الإعداد الأول وحفظ آخر صفحة محفوظة (مع/بدون الخطة الافتراضية).
  Future<void> completeOnboarding({
    required int lastMemorizedPage,
    required bool useDefaultPlan,
  }) async {
    if (useDefaultPlan) {
      settings = PlanSettings.defaults(lastMemorizedPage: lastMemorizedPage);
    } else {
      settings.lastMemorizedPage = lastMemorizedPage;
      // عند الإعداد الأول نضبط نطاق المراجعة ليشمل ما تم حفظه من صفحة 1.
      settings.ranges = [MemorizationRange(start: 1, end: lastMemorizedPage)];
    }
    progress.onboardingDone = true;
    progress.reviewIndex = 0;
    await _persistAll();
    await _notifications.reschedule(settings);
    notifyListeners();
  }

  // ===== حساب أوراد اليوم =====

  ReviewWard get todayReviewWard => ReviewPlanner.computeWard(
        ranges: settings.ranges,
        dailyReviewPages: settings.dailyReviewPages,
        reviewIndex: progress.reviewIndex,
      );

  MemorizationWard get todayMemorizeWard => MemorizationPlanner.computeWard(
        settings: settings,
        weekday: DateTime.now().weekday,
      );

  DayType get todayDayType =>
      settings.dayTypes[DateTime.now().weekday] ?? DayType.memorize;

  bool get reviewCompletedToday =>
      progress.lastReviewCompletedDate == _today;

  bool get memorizeCompletedToday =>
      progress.lastMemorizeCompletedDate == _today;

  // ===== الإكمال =====

  /// إكمال المراجعة: يقدّم مؤشر المراجعة ويسجّل الإنجاز.
  /// لا يتقدّم الورد إلا عند استدعاء هذه الدالة.
  Future<void> completeReview() async {
    if (reviewCompletedToday) return;
    final ward = todayReviewWard;
    if (ward.isEmpty) return;

    progress.reviewIndex = ward.nextIndex;
    progress.lastReviewCompletedDate = _today;
    _recordAchievement(reviewSummary: ward.arabicText);

    await _persistProgress();
    notifyListeners();
  }

  /// إكمال الحفظ: يقدّم آخر صفحة محفوظة (في يوم الحفظ فقط) ويسجّل الإنجاز.
  /// في يوم الربط لا تتم إضافة صفحة جديدة بل يُسجّل الربط فقط.
  /// يُعيد true إذا كان هناك حفظ جديد يمكن إضافته لنطاق المراجعة.
  Future<bool> completeMemorize() async {
    if (memorizeCompletedToday) return false;
    final ward = todayMemorizeWard;
    if (ward.type == DayType.rest) return false;

    bool newPagesMemorized = false;

    if (ward.type == DayType.memorize && ward.segment != null) {
      settings.lastMemorizedPage =
          MemorizationPlanner.advanceAfterMemorize(settings);
      newPagesMemorized = true;
    }

    progress.lastMemorizeCompletedDate = _today;
    _recordAchievement(memorizeSummary: ward.arabicText);

    await _persistAll();
    notifyListeners();
    return newPagesMemorized;
  }

  /// إضافة الصفحات المحفوظة حديثاً إلى نطاق المراجعة (بعد تأكيد المستخدم).
  /// تمدّد آخر نطاق إذا كانت الصفحة متصلة به، وإلا تُنشئ نطاقاً جديداً.
  Future<void> extendReviewRangeToMemorized() async {
    final last = settings.lastMemorizedPage;
    if (settings.ranges.isEmpty) {
      settings.ranges.add(MemorizationRange(start: 1, end: last));
    } else {
      final lastRange = settings.ranges.last;
      if (last > lastRange.end && last <= lastRange.end + settings.memorizeDailyPages + 1) {
        // متصل بآخر نطاق: مدّد النطاق.
        lastRange.end = last;
      } else if (last > lastRange.end) {
        // غير متصل: أنشئ نطاقاً جديداً يبدأ من الصفحة الجديدة.
        final newStart = (last - settings.memorizeDailyPages + 1).clamp(1, last);
        settings.ranges.add(MemorizationRange(start: newStart, end: last));
      }
    }
    await _persistSettings();
    notifyListeners();
  }

  // ===== إدارة نطاقات الحفظ =====

  Future<void> addRange(int start, int end) async {
    settings.ranges.add(MemorizationRange(start: start, end: end));
    await _persistSettings();
    notifyListeners();
  }

  Future<void> updateRange(int index, int start, int end) async {
    if (index < 0 || index >= settings.ranges.length) return;
    settings.ranges[index].start = start;
    settings.ranges[index].end = end;
    await _persistSettings();
    notifyListeners();
  }

  Future<void> deleteRange(int index) async {
    if (index < 0 || index >= settings.ranges.length) return;
    settings.ranges.removeAt(index);
    // إعادة ضبط المؤشر إن أصبح خارج الحدود.
    final total = ReviewPlanner.flatten(settings.ranges).length;
    if (total == 0) {
      progress.reviewIndex = 0;
    } else {
      progress.reviewIndex = progress.reviewIndex % total;
    }
    await _persistAll();
    notifyListeners();
  }

  // ===== تحديث الإعدادات =====

  Future<void> updateSettings(PlanSettings newSettings) async {
    settings = newSettings;
    // الحفاظ على المؤشر ضمن الحدود الجديدة.
    final total = ReviewPlanner.flatten(settings.ranges).length;
    if (total > 0) {
      progress.reviewIndex = progress.reviewIndex % total;
    }
    await _persistAll();
    await _notifications.reschedule(settings);
    notifyListeners();
  }

  Future<void> refreshNotifications() async {
    await _notifications.reschedule(settings);
  }

  // ===== مساعدات داخلية =====

  void _recordAchievement({String? reviewSummary, String? memorizeSummary}) {
    final today = _today;
    final idx = progress.history.indexWhere((h) => h.date == today);
    if (idx >= 0) {
      progress.history[idx] = progress.history[idx].copyWith(
        reviewSummary: reviewSummary,
        memorizeSummary: memorizeSummary,
      );
    } else {
      progress.history.insert(
        0,
        AchievementRecord(
          date: today,
          reviewSummary: reviewSummary,
          memorizeSummary: memorizeSummary,
        ),
      );
    }
  }

  Future<void> _persistSettings() => _storage.saveSettings(settings);
  Future<void> _persistProgress() => _storage.saveProgress(progress);
  Future<void> _persistAll() async {
    await _storage.saveSettings(settings);
    await _storage.saveProgress(progress);
  }
}
