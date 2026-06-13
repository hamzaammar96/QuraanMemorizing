#!/usr/bin/env bash
# سكربت توليد ملفات المنصّات (أندرويد) وتجهيز المشروع للتشغيل.
# يحافظ على كود lib/ و pubspec.yaml الموجودين عبر استرجاعهما من git إن لزم.

set -e

echo "==> توليد مجلدات المنصّات الأصلية (android/ios)..."
flutter create --org com.mutqin --project-name mutqin --platforms=android,ios .

echo "==> استرجاع ملفات المشروع الأصلية في حال تم استبدالها..."
# نحمي الكود والإعدادات الخاصة بنا (آمن لأن المشروع داخل git).
git checkout -- pubspec.yaml lib README.md analysis_options.yaml 2>/dev/null || true

echo "==> تطبيق إعدادات أندرويد (الاسم العربي + أذونات الإشعارات)..."
python3 tool/apply_android_config.py || echo "تنبيه: طبّق إعدادات أندرويد يدوياً حسب README."

echo "==> جلب الحزم..."
flutter pub get

echo "تم. شغّل التطبيق عبر: flutter run"
