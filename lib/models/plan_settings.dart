import 'day_type.dart';
import 'memorization_range.dart';

/// كل إعدادات الخطة القابلة للتخصيص.
/// تحتوي على الخطة الافتراضية الخاصة بالمستخدم، ويمكن تعديلها بالكامل.
class PlanSettings {
  /// عدد صفحات المراجعة اليومية (الافتراضي 10).
  int dailyReviewPages;

  /// آخر صفحة محفوظة (مؤشر تقدم الحفظ).
  int lastMemorizedPage;

  /// نطاقات الحفظ التي تجري مراجعتها (تدعم نطاقات متعددة متفرقة).
  List<MemorizationRange> ranges;

  /// عدد صفحات الحفظ اليومية (الافتراضي 1).
  int memorizeDailyPages;

  /// عدد صفحات الربط المعروضة في يوم الربط (الافتراضي 5).
  int linkPages;

  /// نوع كل يوم من أيام الأسبوع.
  /// المفتاح هو رقم اليوم حسب DateTime.weekday (الإثنين=1 ... الأحد=7).
  Map<int, DayType> dayTypes;

  /// تفعيل أو تعطيل الإشعارات.
  bool notificationsEnabled;

  /// وقت إشعار المراجعة.
  int reviewNotifHour;
  int reviewNotifMinute;

  /// وقت إشعار الحفظ.
  int memorizeNotifHour;
  int memorizeNotifMinute;

  PlanSettings({
    required this.dailyReviewPages,
    required this.lastMemorizedPage,
    required this.ranges,
    required this.memorizeDailyPages,
    required this.linkPages,
    required this.dayTypes,
    required this.notificationsEnabled,
    required this.reviewNotifHour,
    required this.reviewNotifMinute,
    required this.memorizeNotifHour,
    required this.memorizeNotifMinute,
  });

  /// الخطة الافتراضية المطلوبة:
  /// مراجعة 10 صفحات يومياً، حفظ صفحة واحدة 6 أيام،
  /// اليوم السادس (الخميس) ربط لآخر 5 صفحات، والجمعة استراحة.
  factory PlanSettings.defaults({int lastMemorizedPage = 1}) {
    return PlanSettings(
      dailyReviewPages: 10,
      lastMemorizedPage: lastMemorizedPage,
      // النطاق الأول يبدأ من صفحة 1 حتى آخر صفحة محفوظة.
      ranges: [MemorizationRange(start: 1, end: lastMemorizedPage)],
      memorizeDailyPages: 1,
      linkPages: 5,
      dayTypes: {
        DateTime.monday: DayType.memorize,
        DateTime.tuesday: DayType.memorize,
        DateTime.wednesday: DayType.memorize,
        DateTime.thursday: DayType.link, // يوم الربط (اليوم السادس)
        DateTime.friday: DayType.rest, // الجمعة استراحة
        DateTime.saturday: DayType.memorize,
        DateTime.sunday: DayType.memorize,
      },
      notificationsEnabled: true,
      reviewNotifHour: 6,
      reviewNotifMinute: 0,
      memorizeNotifHour: 20,
      memorizeNotifMinute: 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyReviewPages': dailyReviewPages,
        'lastMemorizedPage': lastMemorizedPage,
        'ranges': ranges.map((r) => r.toJson()).toList(),
        'memorizeDailyPages': memorizeDailyPages,
        'linkPages': linkPages,
        'dayTypes':
            dayTypes.map((key, value) => MapEntry(key.toString(), value.name)),
        'notificationsEnabled': notificationsEnabled,
        'reviewNotifHour': reviewNotifHour,
        'reviewNotifMinute': reviewNotifMinute,
        'memorizeNotifHour': memorizeNotifHour,
        'memorizeNotifMinute': memorizeNotifMinute,
      };

  factory PlanSettings.fromJson(Map<String, dynamic> json) {
    final rawDays = (json['dayTypes'] as Map).cast<String, dynamic>();
    final days = <int, DayType>{};
    rawDays.forEach((key, value) {
      days[int.parse(key)] = DayType.fromName(value as String);
    });

    return PlanSettings(
      dailyReviewPages: json['dailyReviewPages'] as int,
      lastMemorizedPage: json['lastMemorizedPage'] as int,
      ranges: (json['ranges'] as List)
          .map((e) => MemorizationRange.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      memorizeDailyPages: json['memorizeDailyPages'] as int,
      linkPages: json['linkPages'] as int,
      dayTypes: days,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      reviewNotifHour: json['reviewNotifHour'] as int,
      reviewNotifMinute: json['reviewNotifMinute'] as int,
      memorizeNotifHour: json['memorizeNotifHour'] as int,
      memorizeNotifMinute: json['memorizeNotifMinute'] as int,
    );
  }

  PlanSettings copy() =>
      PlanSettings.fromJson(toJson());
}
