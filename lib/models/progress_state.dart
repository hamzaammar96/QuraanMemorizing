import 'achievement_record.dart';

/// حالة التقدم المحفوظة محلياً على الجهاز.
/// تحتوي على مؤشرات المراجعة وتواريخ آخر إكمال وسجل الإنجاز.
class ProgressState {
  /// مؤشر المراجعة: موضع الصفحة التالية داخل قائمة صفحات النطاقات المسطّحة.
  /// لا يتقدّم إلا عند الضغط على "إكمال المراجعة".
  int reviewIndex;

  /// تاريخ آخر إكمال للمراجعة (yyyy-MM-dd) أو null.
  String? lastReviewCompletedDate;

  /// تاريخ آخر إكمال للحفظ/الربط (yyyy-MM-dd) أو null.
  String? lastMemorizeCompletedDate;

  /// هل انتهى المستخدم من الإعداد الأول؟
  bool onboardingDone;

  /// سجل الإنجاز اليومي.
  List<AchievementRecord> history;

  ProgressState({
    required this.reviewIndex,
    required this.lastReviewCompletedDate,
    required this.lastMemorizeCompletedDate,
    required this.onboardingDone,
    required this.history,
  });

  factory ProgressState.initial() => ProgressState(
        reviewIndex: 0,
        lastReviewCompletedDate: null,
        lastMemorizeCompletedDate: null,
        onboardingDone: false,
        history: [],
      );

  Map<String, dynamic> toJson() => {
        'reviewIndex': reviewIndex,
        'lastReviewCompletedDate': lastReviewCompletedDate,
        'lastMemorizeCompletedDate': lastMemorizeCompletedDate,
        'onboardingDone': onboardingDone,
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory ProgressState.fromJson(Map<String, dynamic> json) {
    return ProgressState(
      reviewIndex: json['reviewIndex'] as int? ?? 0,
      lastReviewCompletedDate: json['lastReviewCompletedDate'] as String?,
      lastMemorizeCompletedDate: json['lastMemorizeCompletedDate'] as String?,
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      history: (json['history'] as List? ?? [])
          .map((e) =>
              AchievementRecord.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}
