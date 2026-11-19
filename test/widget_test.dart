import 'package:daily_task_app/app/app.dart';
import 'package:daily_task_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('app opens the TodoApp splash with its tagline', (tester) async {
    await tester.pumpWidget(const TodoApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Plan • Organize • Achieve'), findsOneWidget);
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });

  testWidgets('theme controller switches the application to dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(const TodoApp());
    final controller = Get.find<ThemeController>();

    controller.toggleTheme();
    await tester.pump();

    expect(controller.themeMode, ThemeMode.dark);
  });
}
