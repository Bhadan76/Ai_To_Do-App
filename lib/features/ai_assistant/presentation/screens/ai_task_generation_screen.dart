import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';

class AITaskGenerationScreen extends StatelessWidget {
  const AITaskGenerationScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('AI Task Suggestion'),
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.lightPurple,
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 34,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Your generated task',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 14),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Design new UI mockups',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12),
                Text(
                  'Create polished screens for the upcoming product review and share the first draft with your team.',
                ),
                Divider(height: 28),
                Text('Category     Work'),
                SizedBox(height: 10),
                Text('Priority        High'),
                SizedBox(height: 10),
                Text('Due date      Tomorrow, 2:00 PM'),
                SizedBox(height: 10),
                Text('Reminder      30 minutes before'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => Get.toNamed(RouteNames.addTask),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit suggestion'),
        ),
        FilledButton(
          onPressed: () {
            final taskController = Get.find<TaskController>();
            taskController.titleController.text = 'Design new UI mockups';
            taskController.descriptionController.text =
                'Create polished screens for the upcoming product review and share the first draft with your team.';
            taskController.selectedCategory.value = '';
            taskController.selectedPriority.value = 'HIGH';
            taskController.selectedReminder.value = '30 mins before';
            Get.toNamed(RouteNames.addTask);
          },
          child: const Text('Create Task'),
        ),
      ],
    ),
  );
}
