import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../firebase_options.dart';

/// خدمة المصادقة عبر حساب غوغل باستخدام Firebase.
/// تعمل بأمان حتى لو لم تُضبط إعدادات Firebase (تبقى السحابة معطّلة).
class AuthService {
  bool _ready = false;
  bool _gsiInitialized = false;

  /// معرّف عميل OAuth للويب (serverClientId) المطلوب للحصول على idToken
  /// صالح لـ Firebase في تسجيل الدخول الأصلي على أندرويد/iOS.
  static const String _serverClientId =
      '878978217300-63ot75vf47pfpltuvp8fd8lu2dg0khvf.apps.googleusercontent.com';

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

  /// تسجيل الدخول بحساب غوغل.
  /// الويب: نافذة منبثقة. الجوال: منتقي حسابات غوغل الأصلي ثم credential.
  Future<User?> signInWithGoogle() async {
    if (!_ready) return null;

    if (kIsWeb) {
      final cred =
          await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      return cred.user;
    }

    // أندرويد/iOS: تسجيل دخول أصلي (يتجنّب تدفّق المتصفّح غير الموثوق).
    final googleSignIn = GoogleSignIn.instance;
    if (!_gsiInitialized) {
      await googleSignIn.initialize(serverClientId: _serverClientId);
      _gsiInitialized = true;
    }
    final account = await googleSignIn.authenticate();
    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final cred = await FirebaseAuth.instance.signInWithCredential(credential);
    return cred.user;
  }

  Future<void> signOut() async {
    if (!_ready) return;
    if (!kIsWeb && _gsiInitialized) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // تجاهل أي خطأ في تسجيل خروج غوغل الأصلي.
      }
    }
    await FirebaseAuth.instance.signOut();
  }
}

