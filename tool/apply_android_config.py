#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""تطبيق إعدادات أندرويد المطلوبة بعد توليد مجلد android/:
- اسم التطبيق العربي "مُتقِن".
- أذونات الإشعارات والمستقبِلات الخاصة بـ flutter_local_notifications.
- تفعيل core library desugaring المطلوب للمكتبة.
يعمل بشكل آمن (idempotent): لا يكرّر الإضافة إذا كانت موجودة.
"""
import os
import re
import sys

MANIFEST = "android/app/src/main/AndroidManifest.xml"

PERMISSIONS = """    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
"""

RECEIVERS = """        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
"""


def patch_manifest():
    if not os.path.exists(MANIFEST):
        print("لم يُعثر على AndroidManifest.xml — شغّل flutter create أولاً.")
        return
    with open(MANIFEST, encoding="utf-8") as f:
        content = f.read()

    # 1) اسم التطبيق العربي.
    content = re.sub(r'android:label="[^"]*"', 'android:label="مُتقِن"', content, count=1)

    # 2) الأذونات قبل <application> إن لم تكن موجودة.
    if "POST_NOTIFICATIONS" not in content:
        content = content.replace("    <application", PERMISSIONS + "    <application", 1)

    # 3) المستقبِلات داخل <application> قبل إغلاقها إن لم تكن موجودة.
    if "ScheduledNotificationReceiver" not in content:
        content = content.replace("    </application>", RECEIVERS + "    </application>", 1)

    with open(MANIFEST, "w", encoding="utf-8") as f:
        f.write(content)
    print("تم تحديث AndroidManifest.xml")


def patch_gradle():
    """تفعيل desugaring في build.gradle أو build.gradle.kts."""
    groovy = "android/app/build.gradle"
    kts = "android/app/build.gradle.kts"
    if os.path.exists(kts):
        _patch_gradle_kts(kts)
    elif os.path.exists(groovy):
        _patch_gradle_groovy(groovy)


def _patch_gradle_groovy(path):
    with open(path, encoding="utf-8") as f:
        c = f.read()
    if "coreLibraryDesugaringEnabled" not in c:
        c = re.sub(
            r"(compileOptions\s*\{)",
            r"\1\n        coreLibraryDesugaringEnabled true",
            c, count=1,
        )
        if "coreLibraryDesugaringEnabled" not in c:
            # أضف كتلة compileOptions كاملة داخل android { ... }
            c = re.sub(
                r"(android\s*\{)",
                r"\1\n    compileOptions {\n        coreLibraryDesugaringEnabled true\n"
                r"        sourceCompatibility JavaVersion.VERSION_1_8\n"
                r"        targetCompatibility JavaVersion.VERSION_1_8\n    }",
                c, count=1,
            )
    if "desugar_jdk_libs" not in c:
        c = re.sub(
            r"(dependencies\s*\{)",
            r"\1\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'",
            c, count=1,
        )
        if "desugar_jdk_libs" not in c:
            c += "\n\ndependencies {\n    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'\n}\n"
    with open(path, "w", encoding="utf-8") as f:
        f.write(c)
    print("تم تحديث build.gradle (desugaring)")


def _patch_gradle_kts(path):
    with open(path, encoding="utf-8") as f:
        c = f.read()
    if "isCoreLibraryDesugaringEnabled" not in c:
        c = re.sub(
            r"(compileOptions\s*\{)",
            r"\1\n        isCoreLibraryDesugaringEnabled = true",
            c, count=1,
        )
    if "desugar_jdk_libs" not in c:
        c = re.sub(
            r"(dependencies\s*\{)",
            r'\1\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")',
            c, count=1,
        )
        if "desugar_jdk_libs" not in c:
            c += '\n\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")\n}\n'
    with open(path, "w", encoding="utf-8") as f:
        f.write(c)
    print("تم تحديث build.gradle.kts (desugaring)")


if __name__ == "__main__":
    try:
        patch_manifest()
        patch_gradle()
    except Exception as e:  # noqa
        print("خطأ أثناء تطبيق الإعدادات:", e)
        sys.exit(0)  # لا نوقف الإعداد؛ يمكن التطبيق يدوياً.
