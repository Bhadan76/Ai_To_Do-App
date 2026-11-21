import 'package:daily_task_app/app/app.dart';
import 'package:daily_task_app/app/routes/route_names.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('requested destinations can be opened through named routes', (
    tester,
  ) async {
    Get.testMode = true;
    await tester.pumpWidget(const TodoApp());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    for (final route in [
      RouteNames.onboarding,
      RouteNames.login,
      RouteNames.register,
      RouteNames.home,
      RouteNames.addTask,
      RouteNames.taskDetails,
      RouteNames.calendar,
      RouteNames.profile,
      RouteNames.statistics,
      RouteNames.aiAssistant,
      RouteNames.aiTaskGeneration,
    ]) {
      Get.toNamed(route);
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'Route $route failed to render',
      );
    }
  });
}
