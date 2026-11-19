import 'package:get/get.dart';
import '../../../../../shared/models/task_model.dart';
import '../../../../../app/routes/route_names.dart';

class HomeController extends GetxController {
  final RxList<TaskModel> tasks = <TaskModel>[].obs;
  final RxInt selectedNavIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tasks.assignAll(MockTasks.tasks);
  }

  List<TaskModel> get todayTasks =>
      tasks.where((t) => t.dueDate == 'Today').toList();

  int get totalTasks => tasks.length;
  int get completedTasks => tasks.where((t) => t.isCompleted).toList().length;
  int get progressPercent =>
      totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).round();

  void toggleTaskComplete(String id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      tasks.refresh();
    }
  }

  void changeNavIndex(int index) {
    selectedNavIndex.value = index;
    if (index == 0) {
      Get.offAllNamed(RouteNames.home);
    } else if (index == 1) {
      Get.offNamed(RouteNames.calendar);
    } else if (index == 2) {
      Get.toNamed(RouteNames.addTask);
    } else if (index == 3) {
      Get.offNamed(RouteNames.statistics);
    } else if (index == 4) {
      Get.offNamed(RouteNames.profile);
    }
  }
}
