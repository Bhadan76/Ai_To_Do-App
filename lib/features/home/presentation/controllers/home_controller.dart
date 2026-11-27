import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/utils/helpers.dart';
import '../../../../app/routes/route_names.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../tasks/domain/models/task.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';

class HomeController extends GetxController {
  final RxList<TaskEntity> tasks = <TaskEntity>[].obs;
  final RxInt selectedNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[HomeController] onInit initialized');
    Get.find<TaskController>().loadTasks();

    // Initialize FCM and register the device token now that the user is
    // authenticated (covers both login and session restore flows).
    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().initialize();
    }
  }

  /// Tasks due today (any status; completed ones show as struck-through).
  List<TaskEntity> get todayTasks =>
      tasks.where((t) => AppHelpers.isDueToday(t.dueDate)).toList();

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.isCompleted).toList().length;
  int get progressPercent =>
      totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).round();

  void toggleTaskComplete(String id) =>
      Get.find<TaskController>().toggleTaskComplete(id);

  Future<void> refreshTasks() =>
      Get.find<TaskController>().loadTasks(forceRefresh: true);

  void changeNavIndex(int index) {
    debugPrint('[Nav] changeNavIndex: ${selectedNavIndex.value} -> $index');
    // Center button opens the add-task form without changing the active tab.
    if (index == 2) {
      Get.toNamed(RouteNames.addTask);
      return;
    }

    selectedNavIndex.value = index;
  }
}
