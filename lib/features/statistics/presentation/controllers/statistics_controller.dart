import 'package:get/get.dart';
import '../../../../../shared/models/task_model.dart';

class StatisticsController extends GetxController {
  List<TaskModel> get allTasks => MockTasks.tasks;
  int get total => allTasks.length;
  int get completed => allTasks.where((t) => t.isCompleted).length;
  int get pending => total - completed;
  double get progress => total == 0 ? 0 : completed / total;
}
