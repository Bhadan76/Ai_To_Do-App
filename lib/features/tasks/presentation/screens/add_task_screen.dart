import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../controllers/task_controller.dart';

class AddTaskScreen extends GetView<TaskController> {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Add Task'),
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.md),
        children: [
          Container(
            height: 130,
            decoration: BoxDecoration(
              color: AppColors.lightPurple,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.checklist_rounded,
              size: 72,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          AppTextField(
            label: 'Task Title',
            hintText: 'Enter task title',
            controller: controller.titleController,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Description',
            hintText: 'Add a few details',
            controller: controller.descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Obx(
            () => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_month_outlined,
                  color: AppColors.primary,
                ),
                title: const Text('Due Date'),
                subtitle: Text(controller.selectedDueDate.value),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.dueDate.value,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  );
                  if (date != null) controller.setDueDate(date);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: controller.selectedCategory.value,
              decoration: const InputDecoration(labelText: 'Category'),
              items: controller.categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) controller.setCategory(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: controller.selectedPriority.value,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: controller.priorities
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) controller.setPriority(value);
              },
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: controller.selectedReminder.value,
              decoration: const InputDecoration(labelText: 'Reminder'),
              items: controller.reminders
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) controller.selectedReminder.value = value;
              },
            ),
          ),
          const SizedBox(height: 24),
          Obx(
            () => AppPrimaryButton(
              label: 'Add Task',
              isLoading: controller.isLoading.value,
              onPressed: controller.addTask,
            ),
          ),
        ],
      ),
    ),
  );
}
