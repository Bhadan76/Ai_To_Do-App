import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/models/task_model.dart';

class TaskDetailsScreen extends StatelessWidget {
  const TaskDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final task = Get.arguments is TaskModel ? Get.arguments as TaskModel : null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: ListView(
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
            task?.title ?? 'Design new UI',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Center(child: Chip(label: Text(task?.category ?? 'Work'))),
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
                    task?.description.isNotEmpty == true
                        ? task!.description
                        : 'Create a modern and beautiful UI for the todo app.',
                  ),
                  const Divider(height: 28),
                  Text('Due date   •   ${task?.dueDate ?? 'Today'}'),
                  const SizedBox(height: 12),
                  Text('Reminder   •   ${task?.reminder ?? 'On Time'}'),
                  const SizedBox(height: 12),
                  Text('Priority   •   ${task?.priority ?? 'High Priority'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: () => Get.snackbar('Done', 'Task marked as complete'),
            child: const Text('Mark as Complete'),
          ),
          OutlinedButton(
            onPressed: () => Get.toNamed(RouteNames.addTask),
            child: const Text('Edit Task'),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Delete Task',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}
