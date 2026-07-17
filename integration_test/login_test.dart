import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:elct/main.dart' as app;
import 'package:elct/core/widgets/app_text_field.dart';
import 'package:elct/core/widgets/app_button.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('اختبار عملية تسجيل الدخول (Integration Test)', (WidgetTester tester) async {
    // 1. تشغيل التطبيق
    app.main();
    
    // 2. انتظار الشاشة الافتتاحية (Splash Screen) لتنتهي وتنتقل للصفحة الرئيسية
    // الشاشة الافتتاحية تستخدم Future.delayed حقيقي، لذلك نحتاج لانتظار حقيقي
    await Future.delayed(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // 3. في الصفحة الرئيسية، نضغط على تبويب "الملف الشخصي" (Profile) لفتح نافذة تسجيل الدخول
    final profileTab = find.byIcon(Icons.person_outline);
    expect(profileTab, findsOneWidget, reason: 'Profile tab icon not found in bottom nav');
    await tester.tap(profileTab);
    
    // انتظار ظهور النافذة السفلية (Login Required Bottom Sheet)
    await tester.pumpAndSettle(); 

// 4. داخل النافذة السفلية، نضغط على زر "تسجيل الدخول"
    final sheetLoginButton = find.byType(AppButton).first;
    expect(sheetLoginButton, findsWidgets, reason: 'Login button in bottom sheet not found');
    await tester.tap(sheetLoginButton);
    
    // انتظار الانتقال لشاشة تسجيل الدخول (LoginScreen)
    await tester.pumpAndSettle(); 
    
    // 5. الآن يجب أن نكون في شاشة تسجيل الدخول
    final emailField = find.byType(AppTextField).first;
    final passwordField = find.byType(AppTextField).last;
    final loginSubmitButton = find.textContaining('تسجيل');

    expect(emailField, findsOneWidget, reason: 'Email field not found in LoginScreen');
    expect(passwordField, findsOneWidget, reason: 'Password field not found in LoginScreen');

    // 6. كتابة بيانات الدخول
    await tester.enterText(emailField, 'test@example.com');
    await tester.pumpAndSettle();

    await tester.enterText(passwordField, 'password123');
    await tester.pumpAndSettle();

    // 7. الضغط على زر الدخول النهائي
    await tester.tap(loginSubmitButton);
    
    // نعطي التطبيق وقت للتعامل مع الـ Future الخاص بالدخول
    await tester.pumpAndSettle(const Duration(seconds: 2));
    
    // هنا يمكننا إضافة expect للتحقق من اختفاء شاشة الدخول أو الرجوع للـ HomeScreen
    // كمثال نتأكد أننا عدنا للشريط السفلي الذي يحتوي أيقونة Home
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });
}
