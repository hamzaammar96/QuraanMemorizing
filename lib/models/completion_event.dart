/// حدث إنجاز واحد (إكمال مراجعة أو حفظ أو ربط).
/// يُخزّن مقدار التقدّم (delta) ليتيح التراجع بدقّة عن أي حدث.
class CompletionEvent {
  /// معرّف فريد للحدث.
  final String id;

  /// التاريخ بصيغة yyyy-MM-dd.
  final String date;

  /// وقت الإنجاز بصيغة HH:mm.
  final String time;

  /// النوع: 'review' أو 'memorize' أو 'link'.
  final String type;

  /// نص ملخص ما تم إنجازه.
  final String summary;

  /// عدد صفحات المراجعة التي تقدّم بها المؤشر في هذا الحدث (0 لغير المراجعة).
  final int reviewDelta;

  /// عدد صفحات الحفظ الجديدة في هذا الحدث (0 لغير الحفظ).
  final int pageDelta;

  CompletionEvent({
    required this.id,
    required this.date,
    required this.time,
    required this.type,
    required this.summary,
    required this.reviewDelta,
    required this.pageDelta,
  });

  String get typeLabel {
    switch (type) {
      case 'review':
        return 'مراجعة';
      case 'link':
        return 'ربط';
      case 'memorize':
        return 'حفظ';
      default:
        return type;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'type': type,
        'summary': summary,
        'reviewDelta': reviewDelta,
        'pageDelta': pageDelta,
      };

  factory CompletionEvent.fromJson(Map<String, dynamic> json) {
    return CompletionEvent(
      id: json['id'] as String,
      date: json['date'] as String,
      time: json['time'] as String? ?? '',
      type: json['type'] as String,
      summary: json['summary'] as String? ?? '',
      reviewDelta: json['reviewDelta'] as int? ?? 0,
      pageDelta: json['pageDelta'] as int? ?? 0,
    );
  }
}
