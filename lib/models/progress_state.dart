import 'completion_event.dart';

/// حالة التقدم المحفوظة محلياً على الجهاز.
/// تحتوي على مؤشر المراجعة وقائمة أحداث الإنجاز (تدعم التكرار والتراجع).
class ProgressState {
  /// مؤشر المراجعة: موضع الصفحة التالية داخل قائمة صفحات النطاقات المسطّحة.
  /// لا يتقدّم إلا عند الضغط على "إكمال المراجعة".
  int reviewIndex;

  /// هل انتهى المستخدم من الإعداد الأول؟
  bool onboardingDone;

  /// أحداث الإنجاز اليومية (يمكن أن يحدث أكثر من حدث في اليوم).
  List<CompletionEvent> events;

  /// آخر وقت تعديل (ميلي ثانية) — يُستخدم للمزامنة السحابية.
  int lastModified;

  ProgressState({
    required this.reviewIndex,
    required this.onboardingDone,
    required this.events,
    this.lastModified = 0,
  });

  factory ProgressState.initial() => ProgressState(
        reviewIndex: 0,
        onboardingDone: false,
        events: [],
        lastModified: 0,
      );

  Map<String, dynamic> toJson() => {
        'reviewIndex': reviewIndex,
        'onboardingDone': onboardingDone,
        'events': events.map((e) => e.toJson()).toList(),
        'lastModified': lastModified,
      };

  factory ProgressState.fromJson(Map<String, dynamic> json) {
    return ProgressState(
      reviewIndex: json['reviewIndex'] as int? ?? 0,
      onboardingDone: json['onboardingDone'] as bool? ?? false,
      events: (json['events'] as List? ?? [])
          .map((e) =>
              CompletionEvent.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
      lastModified: json['lastModified'] as int? ?? 0,
    );
  }
}
