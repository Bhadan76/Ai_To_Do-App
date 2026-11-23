import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/custom_button.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../controllers/task_controller.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TaskController get controller => Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    String id = '';
    if (args is String) {
      id = args;
    } else if (args != null) {
      try {
        id = (args as dynamic).id?.toString() ?? '';
      } catch (_) {}
    }

    if (id.isNotEmpty) {
      controller.loadTaskDetails(id);
    } else {
      controller.clearForm();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Obx(
        () => Text(controller.isEditingTask ? 'Edit Task' : 'Add Task'),
      ),
      leading: IconButton(
        onPressed: Get.back,
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
      ),
    ),
    body: SafeArea(child: _buildBody(context)),
  );

  Future<void> _showAddCategoryDialog(
    BuildContext context,
    CategoryController categoryController,
    TaskController taskController,
  ) async {
    final nameController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Category'),
          content: Obx(
            () => TextField(
              controller: nameController,
              enabled: !categoryController.isLoading.value,
              decoration: const InputDecoration(
                hintText: 'Enter category name',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: categoryController.isLoading.value
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            Obx(
              () => TextButton(
                onPressed: categoryController.isLoading.value
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Category name cannot be empty',
                          );
                          return;
                        }
                        if (categoryController.categories.any(
                          (c) => c.name.toLowerCase() == name.toLowerCase(),
                        )) {
                          Get.snackbar(
                            'Error',
                            'A category with this name already exists',
                          );
                          return;
                        }
                        final created = await categoryController.createCategory(
                          name,
                        );
                        if (created != null) {
                          await categoryController.loadCategories();
                          taskController.setCategory(created.id);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        }
                      },
                child: categoryController.isLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create'),
              ),
            ),
          ],
        );
      },
    );
    nameController.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingTaskDetails.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final categoryController = Get.find<CategoryController>();

      return ListView(
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
                subtitle: Text(
                  controller.selectedDueDate.value.isEmpty
                      ? 'Select date'
                      : controller.selectedDueDate.value,
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: controller.dueDate.value ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  );
                  if (date != null) controller.setDueDate(date);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Card(
              child: ListTile(
                leading: const Icon(
                  Icons.access_time_rounded,
                  color: AppColors.primary,
                ),
                title: const Text('Due Time'),
                subtitle: Text(
                  controller.dueDate.value == null
                      ? 'Select time'
                      : '${controller.dueDate.value!.hour.toString().padLeft(2, '0')}:${controller.dueDate.value!.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: controller.dueDate.value == null
                        ? TimeOfDay.now()
                        : TimeOfDay.fromDateTime(controller.dueDate.value!),
                  );
                  if (time != null) controller.setDueTime(time);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              key: ValueKey('category:${controller.selectedCategory.value}'),
              // ignore: deprecated_member_use
              value: controller.selectedCategory.value,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                const DropdownMenuItem<String>(
                  value: '',
                  child: Text('No category'),
                ),
                ...categoryController.categories.map(
                  (c) => DropdownMenuItem<String>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
                const DropdownMenuItem<String>(
                  value: '__add_new__',
                  child: Row(
                    children: [
                      Icon(Icons.add, size: 18),
                      SizedBox(width: 6),
                      Text('+ Add New Category'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == '__add_new__') {
                  _showAddCategoryDialog(
                    context,
                    categoryController,
                    controller,
                  );
                  return;
                }
                controller.setCategory(value ?? '');
              },
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              key: ValueKey('priority:${controller.selectedPriority.value}'),
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
            () => SwitchListTile(
              title: const Text('Reminder'),
              subtitle: const Text('Enable a separate reminder'),
              value: controller.reminderEnabled.value,
              onChanged: (v) => controller.setReminderEnabled(v),
            ),
          ),
          Obx(
            () => controller.reminderEnabled.value
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.event_outlined,
                            color: AppColors.primary,
                          ),
                          title: const Text('Reminder Date'),
                          subtitle: Text(
                            controller.selectedReminderAt.value.isEmpty
                                ? 'Select date'
                                : controller.selectedReminderAt.value,
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  controller.reminderAt.value ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365 * 3),
                              ),
                            );
                            if (date != null) controller.setReminderDate(date);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.access_time_rounded,
                            color: AppColors.primary,
                          ),
                          title: const Text('Reminder Time'),
                          subtitle: Text(
                            controller.reminderAt.value == null
                                ? 'Select time'
                                : '${controller.reminderAt.value!.hour.toString().padLeft(2, '0')}:${controller.reminderAt.value!.minute.toString().padLeft(2, '0')}',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: controller.reminderAt.value == null
                                  ? TimeOfDay.now()
                                  : TimeOfDay.fromDateTime(
                                      controller.reminderAt.value!,
                                    ),
                            );
                            if (time != null) controller.setReminderTime(time);
                          },
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          Obx(
            () => AppPrimaryButton(
              label: controller.isEditingTask ? 'Update Task' : 'Add Task',
              isLoading: controller.isLoading.value,
              onPressed: controller.isEditingTask
                  ? controller.updateTask
                  : controller.addTask,
            ),
          ),
        ],
      );
    });
  }
}
