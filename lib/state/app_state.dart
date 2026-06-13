import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../logic/memorization_planner.dart';
import '../logic/review_planner.dart';
import '../models/completion_event.dart';
import '../models/day_type.dart';
import '../models/memorization_range.dart';
import '../models/plan_settings.dart';
import '../models/progress_state.dart';
import '../models/ward.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

/// الحالة المركزية للتطبيق.
/// تربط منطق الخطة (المراجعة والحفظ) بالتخزين والإشعارات والمزامنة السحابية.
class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final NotificationService _notifications = NotificationService();
  final AuthService _auth = AuthService();
  final CloudSyncService _cloud = CloudSyncService();

  late PlanSettings settings;
  late ProgressState progress;
  bool _loaded = false;

  // ===== حالة المزامنة السحابية =====
  User? user;
  String syncStatus = '';
  bool _applyingRemote = false;
  Timer? _pushTimer;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<Map<String, dynamic>?>? _docSub;

  bool get isLoaded => _loaded;
  bool get onboardingDone => _loaded && progress.onboardingDone;

  /// هل أُدخلت إعدادات Firebase؟
  bool get isCloudConfigured => _auth.isConfigured;

  /// هل المزامنة جاهزة (Firebase مهيّأ)؟
  bool get isCloudReady => _auth.isReady;

  bool get isSignedIn => user != null;
  String? get userEmail => user?.email;
  String? get userName => user?.displayName;

  String _dateOf(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  String get _today => _dateOf(DateTime.now());
  String get _now => DateFormat('HH:mm').format(DateTime.now());
  int get _nowMillis => DateTime.now().millisecondsSinceEpoch;

  /// تحميل الإعدادات والتقدم من التخزين عند بدء التطبيق.
  Future<void> load() async {
    final savedSettings = await _storage.loadSettings();
    settings = savedSettings ?? PlanSettings.defaults();
    progress = await _storage.loadProgress();
    _loaded = true;
    await _notifications.init();
    notifyListeners();

    // تهيئة Firebase ومتابعة حالة الدخول (إن كانت الإعدادات موجودة).
    await _auth.initialize();
    if (_auth.isReady) {
      _authSub = _auth.authStateChanges().listen(_onAuthChanged);
    }
  }

  @override
  void dispose() {
    _pushTimer?.cancel();
    _authSub?.cancel();
    _docSub?.cancel();
    super.dispose();
  }

  // ===== المصادقة بحساب غوغل =====

  /// تسجيل الدخول بحساب غوغل.
  Future<void> signInWithGoogle() async {
    if (!_auth.isReady) return;
    syncStatus = 'جارٍ تسجيل الدخول...';
    notifyListeners();
    try {
      await _auth.signInWithGoogle();
    } catch (e) {
      syncStatus = 'تعذّر تسجيل الدخول';
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _onAuthChanged(User? u) async {
    user = u;
    await _docSub?.cancel();
    _docSub = null;
    if (u != null) {
      await _initialSync(u.uid);
      // متابعة التغيّرات لحظياً للمزامنة عبر الأجهزة.
      _docSub = _cloud.watch(u.uid).listen(_onRemote);
    } else {
      syncStatus = '';
    }
    notifyListeners();
  }

  /// أول مزامنة بعد الدخول: ندمج الأحدث بين المحلي والسحابي.
  Future<void> _initialSync(String uid) async {
    syncStatus = 'جارٍ المزامنة...';
    notifyListeners();
    try {
      final remote = await _cloud.fetch(uid);
      if (remote == null) {
        await _pushNow(uid); // لا توجد بيانات سحابية: ارفع المحلي.
      } else {
        final remoteLM = remote['lastModified'] as int? ?? 0;
        if (remoteLM > progress.lastModified) {
          _applyRemote(remote);
        } else if (progress.lastModified > remoteLM) {
          await _pushNow(uid);
        }
      }
      syncStatus = 'تمت المزامنة';
    } catch (e) {
      syncStatus = 'تعذّرت المزامنة';
    }
    notifyListeners();
  }

  /// عند وصول تحديث من السحابة (من جهاز آخر مثلاً).
  void _onRemote(Map<String, dynamic>? data) {
    if (data == null) return;
    final remoteLM = data['lastModified'] as int? ?? 0;
    if (remoteLM > progress.lastModified) {
      _applyRemote(data);
      notifyListeners();
    }
  }

  /// تطبيق البيانات السحابية محلياً دون إعادة رفعها.
  void _applyRemote(Map<String, dynamic> data) {
    _applyingRemote = true;
    try {
      settings =
          PlanSettings.fromJson((data['settings'] as Map).cast<String, dynamic>());
      progress =
          ProgressState.fromJson((data['progress'] as Map).cast<String, dynamic>());
      // حفظ محلي بدون تحديث الطابع الزمني أو إعادة الرفع.
      _storage.saveSettings(settings);
      _storage.saveProgress(progress);
      _notifications.reschedule(settings);
    } finally {
      _applyingRemote = false;
    }
  }

  /// جدولة رفع مؤجّل (debounce) عند تغيّر البيانات محلياً.
  void _schedulePush() {
    if (!_auth.isReady || user == null) return;
    _pushTimer?.cancel();
    _pushTimer = Timer(const Duration(milliseconds: 1500), () {
      _pushNow(user!.uid);
    });
  }

  Future<void> _pushNow(String uid) async {
    try {
      await _cloud.push(
        uid: uid,
        settings: settings.toJson(),
        progress: progress.toJson(),
        lastModified: progress.lastModified,
      );
      syncStatus = 'تمت المزامنة';
      notifyListeners();
    } catch (e) {
      syncStatus = 'تعذّر الرفع';
      notifyListeners();
    }
  }

  // ===== الإعداد الأول =====

  /// إنهاء الإعداد الأول: يُطبّق الخطة الافتراضية مع آخر صفحة محفوظة.
  /// تبقى كل الأرقام قابلة للتعديل لاحقاً من شاشة الإعدادات.
  Future<void> completeOnboarding({required int lastMemorizedPage}) async {
    settings = PlanSettings.defaults(lastMemorizedPage: lastMemorizedPage);
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
        includeFatihaExtra: settings.includeFatihaExtra,
      );

  MemorizationWard get todayMemorizeWard => MemorizationPlanner.computeWard(
        settings: settings,
        weekday: DateTime.now().weekday,
      );

  DayType get todayDayType =>
      settings.dayTypes[DateTime.now().weekday] ?? DayType.memorize;

  /// عدد مرّات إكمال المراجعة اليوم.
  int get reviewCountToday =>
      progress.events.where((e) => e.date == _today && e.type == 'review').length;

  /// عدد مرّات إكمال الحفظ/الربط اليوم.
  int get memorizeCountToday => progress.events
      .where((e) => e.date == _today && (e.type == 'memorize' || e.type == 'link'))
      .length;

  /// آخر حدث إنجاز مسجّل (للتراجع السريع).
  CompletionEvent? get lastEvent =>
      progress.events.isEmpty ? null : progress.events.first;

  /// أحداث يوم معيّن مرتّبة من الأحدث.
  List<CompletionEvent> eventsForDate(DateTime day) {
    final key = _dateOf(day);
    return progress.events.where((e) => e.date == key).toList();
  }

  /// مجموعة التواريخ التي بها إنجاز (لتلوين الرزنامة).
  Set<String> get datesWithEvents =>
      progress.events.map((e) => e.date).toSet();

  // ===== الإكمال (يدعم التكرار خلال اليوم) =====

  /// إكمال المراجعة: يقدّم المؤشر ويسجّل حدثاً. يمكن تكراره عدة مرات في اليوم.
  Future<void> completeReview() async {
    final ward = todayReviewWard;
    if (ward.isEmpty) return;

    final delta = ward.totalPages;
    progress.reviewIndex = ward.nextIndex;
    _addEvent(type: 'review', summary: ward.arabicText, reviewDelta: delta);

    await _persistProgress();
    notifyListeners();
  }

  /// إكمال الحفظ/الربط: في يوم الحفظ يقدّم آخر صفحة محفوظة. يمكن تكراره في اليوم.
  Future<void> completeMemorize() async {
    final ward = todayMemorizeWard;
    if (ward.type == DayType.rest) return;

    int pageDelta = 0;
    String type = 'link';

    if (ward.type == DayType.memorize && ward.segment != null) {
      pageDelta = ward.segment!.pageCount;
      settings.lastMemorizedPage =
          (settings.lastMemorizedPage + pageDelta)
              .clamp(0, MemorizationPlanner.maxPage);
      type = 'memorize';
      // مزامنة نطاق المراجعة تلقائياً مع ما تم حفظه (إن كان متصلاً).
      _autoExtendReviewRange();
    }

    _addEvent(type: type, summary: ward.arabicText, pageDelta: pageDelta);

    await _persistAll();
    notifyListeners();
  }

  // ===== التراجع عن الإنجاز =====

  /// التراجع عن حدث إنجاز معيّن (يعيد المؤشرات إلى ما قبله).
  Future<void> undoEvent(String eventId) async {
    final idx = progress.events.indexWhere((e) => e.id == eventId);
    if (idx < 0) return;
    final e = progress.events[idx];

    // التراجع باستخدام المقدار (delta) — آمن لأي حدث.
    if (e.reviewDelta != 0) {
      final total = ReviewPlanner.flatten(settings.ranges).length;
      if (total > 0) {
        progress.reviewIndex =
            ((progress.reviewIndex - e.reviewDelta) % total + total) % total;
      }
    }
    if (e.pageDelta != 0) {
      settings.lastMemorizedPage =
          (settings.lastMemorizedPage - e.pageDelta).clamp(0, MemorizationPlanner.maxPage);
    }

    progress.events.removeAt(idx);
    await _persistAll();
    notifyListeners();
  }

  /// التراجع عن آخر إنجاز مسجّل.
  Future<void> undoLastEvent() async {
    final e = lastEvent;
    if (e != null) await undoEvent(e.id);
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
    final total = ReviewPlanner.flatten(settings.ranges).length;
    progress.reviewIndex = total == 0 ? 0 : progress.reviewIndex % total;
    await _persistAll();
    notifyListeners();
  }

  // ===== تحديث الإعدادات =====

  Future<void> updateSettings(PlanSettings newSettings) async {
    settings = newSettings;
    final total = ReviewPlanner.flatten(settings.ranges).length;
    if (total > 0) progress.reviewIndex = progress.reviewIndex % total;
    await _persistAll();
    await _notifications.reschedule(settings);
    notifyListeners();
  }

  Future<void> refreshNotifications() => _notifications.reschedule(settings);

  // ===== مساعدات داخلية =====

  /// تمديد آخر نطاق مراجعة تلقائياً ليشمل ما تم حفظه إن كان متصلاً به.
  void _autoExtendReviewRange() {
    final last = settings.lastMemorizedPage;
    if (settings.ranges.isEmpty) {
      settings.ranges.add(MemorizationRange(start: 1, end: last));
      return;
    }
    final lastRange = settings.ranges.last;
    if (last > lastRange.end && last <= lastRange.end + settings.memorizeDailyPages) {
      lastRange.end = last; // متصل: مدّد النطاق
    }
  }

  void _addEvent({
    required String type,
    required String summary,
    int reviewDelta = 0,
    int pageDelta = 0,
  }) {
    progress.events.insert(
      0,
      CompletionEvent(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: _today,
        time: _now,
        type: type,
        summary: summary,
        reviewDelta: reviewDelta,
        pageDelta: pageDelta,
      ),
    );
  }

  Future<void> _persistSettings() => _persist();
  Future<void> _persistProgress() => _persist();
  Future<void> _persistAll() => _persist();

  /// حفظ محلي + تحديث الطابع الزمني + جدولة رفع سحابي (إن كان مسجّلاً الدخول).
  Future<void> _persist() async {
    if (!_applyingRemote) {
      progress.lastModified = _nowMillis;
    }
    await _storage.saveSettings(settings);
    await _storage.saveProgress(progress);
    if (!_applyingRemote) _schedulePush();
  }
}
