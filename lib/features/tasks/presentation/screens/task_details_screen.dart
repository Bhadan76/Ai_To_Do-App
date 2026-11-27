import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../domain/models/task.dart';
import '../controllers/task_controller.dart';

class TaskDetailsScreen extends StatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  TaskController get controller => Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    String taskId = '';
    if (args is String) {
      taskId = args;
    } else if (args != null) {
      try {
        taskId = (args as dynamic).id?.toString() ?? '';
      } catch (_) {}
    }

    if (taskId.isNotEmpty) {
      controller.loadTaskDetails(taskId);
    } else if (args != null) {
      try {
        controller.currentTask.value = args as dynamic;
        controller.currentTaskId.value = (args as dynamic).id?.toString() ?? '';
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Obx(() {
        final task = controller.currentTask.value;

        if (controller.isLoadingTaskDetails.value || task == null) {
          if (controller.currentTaskId.value.isEmpty) {
            return const EmptyState(
              title: 'Task not found',
              message: 'Select a task from the list.',
              icon: Icons.assignment_outlined,
            );
          }
          return const Center(child: CircularProgressIndicator());
        }

        final categoryName = AppHelpers.firstWhereOrNull(
          Get.find<CategoryController>().categories,
          (c) => c.id == task.categoryId,
        )?.name;

        return ListView(
          padding: const EdgeInsets.all(22),
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.lightPurple,
                child: const Icon(
                  Icons.task_alt_rounded,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Center(child: Chip(label: Text(categoryName ?? 'No category'))),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description != null && task.description!.isNotEmpty
                          ? task.description!
                          : 'No description provided',
                    ),
                    const Divider(height: 28),
                    Text(
                      'Due date   •   ${AppHelpers.formatDateTime(task.dueDate)}',
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Reminder   •   ${task.reminderAt != null ? AppHelpers.formatDateTime(task.reminderAt) : 'On Time'}',
                    ),
                    if (task.reminderAt != null &&
                        task.reminderAt!.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI Smart Reminder • Scheduled',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Text('Priority   •   ${task.priority}'),
                    const SizedBox(height: 12),
                    Text('Status      •   ${task.status}'),
                    if (task.completedAt != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Completed   •   ${AppHelpers.formatDateTime(task.completedAt)}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              key: ValueKey('status:${controller.selectedStatus.value}'),
              initialValue: controller.selectedStatus.value,
              decoration: const InputDecoration(labelText: 'Status'),
              items: TaskEntity.statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.updateStatus(task.id, value);
                }
              },
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => controller.updateStatus(
                task.id,
                task.isCompleted
                    ? TaskEntity.statusTodo
                    : TaskEntity.statusCompleted,
              ),
              child: Text(
                task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
              ),
            ),
            OutlinedButton(
              onPressed: () =>
                  Get.toNamed(RouteNames.addTask, arguments: task.id),
              child: const Text('Edit Task'),
            ),
            TextButton(
              onPressed: () => Get.defaultDialog(
                title: 'Delete Task',
                middleText: 'Are you sure you want to delete this task?',
                textConfirm: 'Delete',
                onConfirm: () {
                  controller.deleteTask(task.id);
                  Get.back();
                  Get.back();
                },
                barrierDismissible: false,
              ),
              child: Text(
                'Delete Task',
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        );
      }),
    );
  }
}
