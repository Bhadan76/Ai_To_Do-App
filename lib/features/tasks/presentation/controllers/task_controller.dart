import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../shared/models/task_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class TaskController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedCategory = 'Work'.obs;
  final RxString selectedPriority = 'Normal'.obs;
  final RxString selectedDueDate = 'Today, 9:00 PM'.obs;
  final Rx<DateTime> dueDate = DateTime.now().obs;
  final RxString selectedReminder = 'On Time'.obs;
  final RxBool isLoading = false.obs;

  final List<String> categories = ['Work', 'Personal', 'Health', 'Study'];
  final List<String> priorities = ['Low', 'Normal', 'High Priority'];
  final List<String> reminders = [
    'On Time',
    '5 mins before',
    '10 mins before',
    '30 mins before',
  ];

  void setCategory(String cat) => selectedCategory.value = cat;
  void setPriority(String p) => selectedPriority.value = p;

  void setDueDate(DateTime date) {
    dueDate.value = date;
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    selectedDueDate.value = isToday
        ? 'Today, 9:00 PM'
        : '${date.month}/${date.day}/${date.year}, 9:00 PM';
  }

  void addTask() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a task title');
      return;
    }
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      category: selectedCategory.value,
      priority: selectedPriority.value,
      dueDate:
          dueDate.value.year == DateTime.now().year &&
              dueDate.value.month == DateTime.now().month &&
              dueDate.value.day == DateTime.now().day
          ? 'Today'
          : '${dueDate.value.month}/${dueDate.value.day}/${dueDate.value.year}',
      dueTime: '9:00 PM',
      reminder: selectedReminder.value,
    );
    MockTasks.tasks.add(task);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().tasks.add(task);
    }
    isLoading.value = false;
    Get.back();
    Get.snackbar('Success', 'Task added successfully');
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
