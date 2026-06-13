import 'package:cloud_firestore/cloud_firestore.dart';

/// خدمة المزامنة السحابية عبر Cloud Firestore.
/// تُخزّن بيانات كل مستخدم في مستند users/{uid}.
class CloudSyncService {
  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection('users');

  DocumentReference<Map<String, dynamic>> _doc(String uid) => _users.doc(uid);

  /// رفع البيانات إلى السحابة.
  Future<void> push({
    required String uid,
    required Map<String, dynamic> settings,
    required Map<String, dynamic> progress,
    required int lastModified,
  }) async {
    await _doc(uid).set({
      'settings': settings,
      'progress': progress,
      'lastModified': lastModified,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// جلب البيانات المخزّنة (أو null إن لم توجد).
  Future<Map<String, dynamic>?> fetch(String uid) async {
    final snap = await _doc(uid).get();
    return snap.data();
  }

  /// متابعة تغيّرات البيانات لحظياً (للمزامنة عبر الأجهزة).
  Stream<Map<String, dynamic>?> watch(String uid) {
    return _doc(uid).snapshots().map((s) => s.data());
  }
}
