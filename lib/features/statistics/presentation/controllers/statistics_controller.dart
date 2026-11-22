import 'package:get/get.dart';

import '../../../tasks/domain/models/task.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class StatisticsController extends GetxController {
  List<TaskEntity> get allTasks => Get.find<HomeController>().tasks;

  int get total => allTasks.length;
  int get completed => allTasks.where((t) => t.isCompleted).length;
  int get pending => total - completed;
  double get progress => total == 0 ? 0 : completed / total;
}
