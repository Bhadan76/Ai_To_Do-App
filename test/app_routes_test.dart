import 'package:daily_task_app/app/routes/app_pages.dart';
import 'package:daily_task_app/app/routes/route_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'the canonical GetX route table exposes every requested destination',
    () {
      final routeNames = AppPages.pages.map((page) => page.name).toSet();

      expect(
        routeNames,
        containsAll({
          RouteNames.splash,
          RouteNames.onboarding,
          RouteNames.login,
          RouteNames.register,
          RouteNames.home,
          RouteNames.addTask,
          RouteNames.taskDetails,
          RouteNames.calendar,
          RouteNames.profile,
          RouteNames.statistics,
          RouteNames.categories,
          RouteNames.aiAssistant,
          RouteNames.aiTaskGeneration,
        }),
      );
    },
  );
}
