/// سجل إنجاز ليوم واحد: يوضّح ما تم إكماله من مراجعة أو حفظ/ربط.
class AchievementRecord {
  /// التاريخ بصيغة yyyy-MM-dd.
  final String date;

  /// نص ملخص المراجعة المنجزة (إن وجدت).
  final String? reviewSummary;

  /// نص ملخص الحفظ/الربط المنجز (إن وجد).
  final String? memorizeSummary;

  AchievementRecord({
    required this.date,
    this.reviewSummary,
    this.memorizeSummary,
  });

  AchievementRecord copyWith({
    String? reviewSummary,
    String? memorizeSummary,
  }) {
    return AchievementRecord(
      date: date,
      reviewSummary: reviewSummary ?? this.reviewSummary,
      memorizeSummary: memorizeSummary ?? this.memorizeSummary,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'reviewSummary': reviewSummary,
        'memorizeSummary': memorizeSummary,
      };

  factory AchievementRecord.fromJson(Map<String, dynamic> json) {
    return AchievementRecord(
      date: json['date'] as String,
      reviewSummary: json['reviewSummary'] as String?,
      memorizeSummary: json['memorizeSummary'] as String?,
    );
  }
}
