import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../lib/core/di/injection.dart';

class TestUtils {
  static Widget createTestApp(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) {
        return MaterialApp(
          home: child,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
        );
      },
    );
  }

  static Future<void> setupTestDependencies() async {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();
  }

  // WidgetTester se crea automáticamente en los tests
  // No necesitamos crear uno manualmente

  static Future<void> pumpWidget(
    WidgetTester tester,
    Widget widget, {
    Duration? duration,
  }) async {
    await tester.pumpWidget(createTestApp(widget));
    if (duration != null) {
      await tester.pump(duration);
    }
  }

  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump();
  }

  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pump();
  }

  static Future<void> scroll(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 500);
    await tester.pump();
  }

  static Finder findText(String text) {
    return find.text(text);
  }

  static Finder findWidget<T extends Widget>() {
    return find.byType(T);
  }

  static Finder findByKey(Key key) {
    return find.byKey(key);
  }

  static Finder findIcon(IconData icon) {
    return find.byIcon(icon);
  }

  static void expectWidgetExists(Finder finder) {
    expect(finder, findsOneWidget);
  }

  static void expectWidgetDoesNotExist(Finder finder) {
    expect(finder, findsNothing);
  }

  static void expectMultipleWidgets(Finder finder, int count) {
    expect(finder, findsNWidgets(count));
  }

  static void expectTextExists(String text) {
    expect(findText(text), findsOneWidget);
  }

  static void expectTextDoesNotExist(String text) {
    expect(findText(text), findsNothing);
  }
}
