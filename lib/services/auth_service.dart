import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// خدمة المصادقة عبر حساب غوغل باستخدام Firebase.
/// تعمل بأمان حتى لو لم تُضبط إعدادات Firebase (تبقى السحابة معطّلة).
class AuthService {
  bool _ready = false;

  /// هل Firebase مهيّأ وجاهز للاستخدام؟
  bool get isReady => _ready;

  /// هل أُدخلت إعدادات Firebase أصلاً؟
  bool get isConfigured => DefaultFirebaseOptions.isConfigured;

  /// تهيئة Firebase إن وُجدت الإعدادات.
  Future<void> initialize() async {
    if (!isConfigured) return;
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _ready = true;
    } catch (e) {
      // في حال فشل التهيئة نتابع في الوضع المحلي دون إيقاف التطبيق.
      debugPrint('Firebase init failed: $e');
      _ready = false;
    }
  }

  User? get currentUser => _ready ? FirebaseAuth.instance.currentUser : null;

  /// تيار تغيّر حالة تسجيل الدخول.
  Stream<User?> authStateChanges() {
    if (!_ready) return const Stream.empty();
    return FirebaseAuth.instance.authStateChanges();
  }

  /// تسجيل الدخول بحساب غوغل (نافذة منبثقة على الويب، وتدفّق أصلي على الجوال).
  Future<User?> signInWithGoogle() async {
    if (!_ready) return null;
    final provider = GoogleAuthProvider();
    UserCredential cred;
    if (kIsWeb) {
      cred = await FirebaseAuth.instance.signInWithPopup(provider);
    } else {
      cred = await FirebaseAuth.instance.signInWithProvider(provider);
    }
    return cred.user;
  }

  Future<void> signOut() async {
    if (!_ready) return;
    await FirebaseAuth.instance.signOut();
  }
}
