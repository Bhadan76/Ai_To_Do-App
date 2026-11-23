// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api_error_response.dart';
import '../../../../core/utils/helpers.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../domain/models/task.dart';
import '../../domain/usecases/task_usecases.dart';

class TaskController extends GetxController {
  TaskController({
    required CreateTaskUseCase createTaskUseCase,
    required ListTasksUseCase listTasksUseCase,
    required GetTaskByIdUseCase getTaskByIdUseCase,
    required UpdateTaskUseCase updateTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required RefreshTasksUseCase refreshTasksUseCase,
  }) : _createTaskUseCase = createTaskUseCase,
       _listTasksUseCase = listTasksUseCase,
       _getTaskByIdUseCase = getTaskByIdUseCase,
       _updateTaskUseCase = updateTaskUseCase,
       _deleteTaskUseCase = deleteTaskUseCase,
       _refreshTasksUseCase = refreshTasksUseCase;

  final CreateTaskUseCase _createTaskUseCase;
  final ListTasksUseCase _listTasksUseCase;
  final GetTaskByIdUseCase _getTaskByIdUseCase;
  final UpdateTaskUseCase _updateTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final RefreshTasksUseCase _refreshTasksUseCase;

  // Add Task form state.
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedCategory = ''.obs; // category ID, '' = none
  final RxString selectedPriority = 'MEDIUM'.obs;
  final RxString selectedDueDate = ''.obs; // display string
  final Rx<DateTime?> dueDate = Rx<DateTime?>(null);
  final Rx<DateTime?> reminderAt = Rx<DateTime?>(null);
  final RxBool reminderEnabled = false.obs;
  final RxString selectedReminderAt = ''.obs; // display string for reminder
  final RxString selectedReminder = 'On Time'.obs;
  final RxString selectedStatus = 'TODO'.obs; // edit mode on details screen
  final RxBool isLoading = false.obs;

  // Task list state (HomeScreen and AllTasksScreen).
  final RxBool isLoadingTasks = false.obs;

  // Filters applied when loading tasks.
  final RxString filterStatus = ''.obs;
  final RxString filterPriority = ''.obs;
  final RxString filterCategoryId = ''.obs;
  final RxString sortBy = 'createdAt'.obs;
  final RxString sortOrder = 'desc'.obs;

  // Task details state (TaskDetailsScreen).
  final Rx<TaskEntity?> currentTask = Rx<TaskEntity?>(null);
  final RxString currentTaskId = ''.obs;
  final RxBool isLoadingTaskDetails = false.obs;

  final List<String> priorities = TaskEntity.priorities;

  static const List<String> reminderLabels = [
    'On Time',
    '5 mins before',
    '10 mins before',
    '30 mins before',
  ];

  static const Map<String, Duration?> reminderOffsets = {
    'On Time': null,
    '5 mins before': Duration(minutes: 5),
    '10 mins before': Duration(minutes: 10),
    '30 mins before': Duration(minutes: 30),
  };

  bool get isEditingTask => currentTaskId.value.isNotEmpty;

  bool get isReminderValid {
    if (!reminderEnabled.value) return true;
    final r = reminderAt.value;
    final d = dueDate.value;
    if (r == null) return false;
    if (d == null) return true;
    return !r.isAfter(d);
  }

  String? get reminderValidationError {
    if (!reminderEnabled.value) return null;
    final r = reminderAt.value;
    final d = dueDate.value;
    if (r == null) return 'Select reminder date and time';
    if (d != null && r.isAfter(d)) {
      return 'Reminder must not be after due date';
    }
    return null;
  }

  bool validateReminder() => isReminderValid;

  String? validate() => reminderValidationError;

  // ── Task list ────────────────────────────────────────────────────

  Future<void> loadTasks({int page = 1, int pageSize = 20}) async {
    if (Get.testMode) return;
    isLoadingTasks.value = true;
    try {
      final result = await _listTasksUseCase.call(
        page: page,
        pageSize: pageSize,
        status: filterStatus.value.isEmpty ? null : filterStatus.value,
        priority: filterPriority.value.isEmpty ? null : filterPriority.value,
        categoryId: filterCategoryId.value.isEmpty
            ? null
            : filterCategoryId.value,
        sortBy: sortBy.value,
        sortOrder: sortOrder.value,
      );
      Get.find<HomeController>().tasks.assignAll(result.items);
    } on ApiErrorResponse catch (e) {
      _showSnackbar('Error', _errorMessage(e));
    } on TaskException catch (e) {
      _showSnackbar('Error', e.message);
    } catch (_) {
      _showSnackbar('Error', 'Failed to load tasks. Please try again.');
    } finally {
      isLoadingTasks.value = false;
    }
  }

  Future<void> refreshTasks({int page = 1, int pageSize = 20}) async {
    final result = await _refreshTasksUseCase.call(
      page: page,
      pageSize: pageSize,
    );
    Get.find<HomeController>().tasks.assignAll(result.items);
  }

  // ── Add Task ─────────────────────────────────────────────────────

  void setCategory(String categoryId) => selectedCategory.value = categoryId;

  void setPriority(String priority) => selectedPriority.value = priority;

  void setDueDate(DateTime date) {
    final prev = dueDate.value;
    int hour;
    int minute;
    if (date.hour != 0 || date.minute != 0) {
      hour = date.hour;
      minute = date.minute;
    } else if (prev != null) {
      hour = prev.hour;
      minute = prev.minute;
    } else {
      final now = DateTime.now();
      hour = now.hour;
      minute = now.minute;
    }
    dueDate.value = DateTime(date.year, date.month, date.day, hour, minute);
    _setDueDateDisplay();
  }

  void setDueDateOnly(DateTime date) => setDueDate(date);

  void setDueTime(TimeOfDay time) {
    final prev = dueDate.value ?? DateTime.now();
    dueDate.value = DateTime(
      prev.year,
      prev.month,
      prev.day,
      time.hour,
      time.minute,
    );
    _setDueDateDisplay();
  }

  void setDueDateTime(DateTime dateTime) {
    dueDate.value = dateTime;
    _setDueDateDisplay();
  }

  void setDueDateAndTime(DateTime date, TimeOfDay time) {
    dueDate.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    _setDueDateDisplay();
  }

  // ── Reminder (independent date + time) ──────────────────────────

  void setReminderEnabled(bool value) {
    reminderEnabled.value = value;
    if (!value) {
      reminderAt.value = null;
      _setReminderDisplay();
      return;
    }
    reminderAt.value ??= DateTime.now();
    _setReminderDisplay();
  }

  void enableReminder() => setReminderEnabled(true);

  void disableReminder() => setReminderEnabled(false);

  void toggleReminder() => setReminderEnabled(!reminderEnabled.value);

  void setReminderDate(DateTime date) {
    final prev = reminderAt.value;
    int hour;
    int minute;
    if (date.hour != 0 || date.minute != 0) {
      hour = date.hour;
      minute = date.minute;
    } else if (prev != null) {
      hour = prev.hour;
      minute = prev.minute;
    } else {
      final now = DateTime.now();
      hour = now.hour;
      minute = now.minute;
    }
    reminderAt.value = DateTime(date.year, date.month, date.day, hour, minute);
    reminderEnabled.value = true;
    _setReminderDisplay();
  }

  void setReminderTime(TimeOfDay time) {
    final prev = reminderAt.value ?? DateTime.now();
    reminderAt.value = DateTime(
      prev.year,
      prev.month,
      prev.day,
      time.hour,
      time.minute,
    );
    reminderEnabled.value = true;
    _setReminderDisplay();
  }

  void setReminderDateTime(DateTime dateTime) {
    reminderAt.value = dateTime;
    reminderEnabled.value = true;
    _setReminderDisplay();
  }

  void setReminderDateAndTime(DateTime date, TimeOfDay time) {
    reminderAt.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    reminderEnabled.value = true;
    _setReminderDisplay();
  }

  void setReminder(String label) {
    selectedReminder.value = label;
    if (label == 'On Time') {
      if (dueDate.value != null) {
        reminderAt.value = dueDate.value;
        reminderEnabled.value = true;
        _setReminderDisplay();
      }
      return;
    }
    final offset = reminderOffsets[label];
    if (offset != null && dueDate.value != null) {
      reminderAt.value = dueDate.value!.subtract(offset);
      reminderEnabled.value = true;
      _setReminderDisplay();
    }
  }

  void _setDueDateDisplay() {
    final due = dueDate.value;
    selectedDueDate.value = due == null
        ? ''
        : AppHelpers.formatLocalDateTime(due);
  }

  void _setReminderDisplay() {
    final r = reminderAt.value;
    selectedReminderAt.value = r == null
        ? ''
        : AppHelpers.formatLocalDateTime(r);
  }

  Future<void> addTask() async {
    if (titleController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter a task title');
      return;
    }
    if (!isReminderValid) {
      _showSnackbar('Error', reminderValidationError ?? 'Invalid reminder');
      return;
    }
    isLoading.value = true;
    try {
      final task = await _createTaskUseCase.call(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        dueDate: dueDate.value == null
            ? null
            : AppHelpers.toIso8601(dueDate.value!),
        categoryId: _resolveCategoryId(),
        priority: selectedPriority.value,
        reminderAt: reminderEnabled.value && reminderAt.value != null
            ? AppHelpers.toIso8601(reminderAt.value!)
            : null,
      );
      _setTaskOnHome(task);
      await Get.find<HomeController>().refreshTasks();
      clearForm();
      Get.back();
      _showSnackbar('Success', 'Task added successfully');
    } on ApiErrorResponse catch (e) {
      _showSnackbar('Error', _errorMessage(e));
    } on TaskException catch (e) {
      _showSnackbar('Error', e.message);
    } catch (_) {
      _showSnackbar('Error', 'Failed to add task. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Clears all add-task form fields.
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    dueDate.value = null;
    selectedDueDate.value = '';
    reminderAt.value = null;
    reminderEnabled.value = false;
    selectedReminderAt.value = '';
    selectedCategory.value = '';
    selectedPriority.value = 'MEDIUM';
    selectedReminder.value = 'On Time';
    currentTaskId.value = '';
    currentTask.value = null;
    isLoadingTaskDetails.value = false;
  }

  /// Resolves the selected category label/ID into a category ID.
  String? _resolveCategoryId() {
    final value = selectedCategory.value.trim();
    if (value.isEmpty) return null;
    if (!Get.isRegistered<CategoryController>()) return value;
    final categories = Get.find<CategoryController>().categories;
    final byId = AppHelpers.firstWhereOrNull(categories, (c) => c.id == value);
    if (byId != null) return byId.id;
    // Legacy fallback: the value may be a category name (set by other
    // screens such as the AI suggestion screen).
    final byName = AppHelpers.firstWhereOrNull(
      categories,
      (c) => c.name.toLowerCase() == value.toLowerCase(),
    );
    return byName?.id;
  }

  // ── Task details / update / delete ───────────────────────────────

  void _populateFormFromTask(TaskEntity task) {
    currentTask.value = task;
    currentTaskId.value = task.id;
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
    dueDate.value = AppHelpers.parseIso8601(task.dueDate);
    _setDueDateDisplay();
    reminderAt.value = AppHelpers.parseIso8601(task.reminderAt);
    reminderEnabled.value = reminderAt.value != null;
    _setReminderDisplay();
    selectedCategory.value = task.categoryId ?? '';
    selectedPriority.value = task.priority;
    selectedStatus.value = task.status;
    _setReminderFromTask(task);
  }

  Future<void> loadTaskDetails(String id) async {
    if (id.isEmpty) {
      currentTask.value = null;
      currentTaskId.value = '';
      isLoadingTaskDetails.value = false;
      return;
    }

    final existing = currentTask.value;
    if (existing != null && existing.id == id) {
      _populateFormFromTask(existing);
      isLoadingTaskDetails.value = false;
    } else {
      isLoadingTaskDetails.value = true;
    }

    if (Get.testMode) {
      isLoadingTaskDetails.value = false;
      return;
    }

    try {
      final task = await _getTaskByIdUseCase.call(id);
      _populateFormFromTask(task);
    } on ApiErrorResponse catch (e) {
      if (existing == null) {
        currentTask.value = null;
        currentTaskId.value = '';
      }
      _showSnackbar('Error', _errorMessage(e));
    } on TaskException catch (e) {
      if (existing == null) {
        currentTask.value = null;
        currentTaskId.value = '';
      }
      _showSnackbar('Error', e.message);
    } catch (_) {
      if (existing == null) {
        currentTask.value = null;
        currentTaskId.value = '';
      }
      _showSnackbar('Error', 'Failed to load task details. Please try again.');
    } finally {
      isLoadingTaskDetails.value = false;
    }
  }

  Future<void> updateTask() async {
    final task = currentTask.value;
    if (task == null) {
      addTask();
      return;
    }
    final title = titleController.text.trim();
    if (title.isEmpty) {
      _showSnackbar('Error', 'Please enter a task title');
      return;
    }
    if (!isReminderValid) {
      _showSnackbar('Error', reminderValidationError ?? 'Invalid reminder');
      return;
    }
    isLoading.value = true;
    try {
      final categoryId = _resolveCategoryId();
      final clearCategory =
          selectedCategory.value.isEmpty && task.categoryId != null;
      final shouldClearReminder =
          !reminderEnabled.value && task.reminderAt != null;
      final updated = await _updateTaskUseCase.call(
        task.id,
        title: title,
        description: descriptionController.text.trim(),
        dueDate: dueDate.value == null
            ? null
            : AppHelpers.toIso8601(dueDate.value!),
        categoryId: categoryId,
        clearCategory: clearCategory,
        priority: selectedPriority.value,
        reminderAt: reminderEnabled.value && reminderAt.value != null
            ? AppHelpers.toIso8601(reminderAt.value!)
            : null,
        clearReminder: shouldClearReminder,
      );
      _setTaskOnHome(updated);
      currentTask.value = updated;
      selectedStatus.value = updated.status;
      await Get.find<HomeController>().refreshTasks();
      Get.back();
      _showSnackbar('Success', 'Task updated successfully');
    } on ApiErrorResponse catch (e) {
      _showSnackbar('Error', _errorMessage(e));
    } on TaskException catch (e) {
      _showSnackbar('Error', e.message);
    } catch (_) {
      _showSnackbar('Error', 'Failed to update task. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Updates only the status (used by the details screen and toggling).
  Future<void> updateStatus(String id, String status) async {
    isLoading.value = true;
    try {
      final updated = await _updateTaskUseCase.call(id, status: status);
      _setTaskOnHome(updated);
      if (id == currentTaskId.value) {
        currentTask.value = updated;
        selectedStatus.value = updated.status;
      }
      await Get.find<HomeController>().refreshTasks();
      _showSnackbar('Success', 'Task updated successfully');
    } on ApiErrorResponse catch (e) {
      _showSnackbar('Error', _errorMessage(e));
    } on TaskException catch (e) {
      _showSnackbar('Error', e.message);
    } catch (_) {
      _showSnackbar('Error', 'Failed to update task. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggles completion of a task: COMPLETED <-> TODO.
  Future<void> toggleTaskComplete(String id) async {
    final home = Get.find<HomeController>();
    final current = AppHelpers.firstWhereOrNull(home.tasks, (t) => t.id == id);
    if (current == null) return;
    final newStatus = current.isCompleted
        ? TaskEntity.statusTodo
        : TaskEntity.statusCompleted;
    await updateStatus(id, newStatus);
  }

  Future<void> deleteTask(String id) async {
    isLoading.value = true;
    try {
      await _deleteTaskUseCase.call(id);
      Get.find<HomeController>().tasks.removeWhere((t) => t.id == id);
      if (currentTaskId.value == id) {
        currentTask.value = null;
        currentTaskId.value = '';
      }
      await Get.find<HomeController>().refreshTasks();
      _showSnackbar('Success', 'Task deleted successfully');
    } on ApiErrorResponse catch (e) {
      _showSnackbar('Error', _errorMessage(e));
    } on TaskException catch (e) {
      _showSnackbar('Error', e.message);
    } catch (_) {
      _showSnackbar('Error', 'Failed to delete task. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────

  void _setTaskOnHome(TaskEntity task) {
    final home = Get.find<HomeController>();
    final index = home.tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      home.tasks[index] = task;
    } else {
      home.tasks.add(task);
    }
  }

  void _setReminderFromTask(TaskEntity task) {
    final parsed = AppHelpers.parseIso8601(task.reminderAt);
    reminderAt.value = parsed;
    reminderEnabled.value = parsed != null;
    _setReminderDisplay();
    if (parsed == null) {
      selectedReminder.value = 'On Time';
      return;
    }
    final due = AppHelpers.parseIso8601(task.dueDate);
    if (due != null) {
      final diffMinutes = due.difference(parsed).inMinutes;
      selectedReminder.value = _labelForOffset(diffMinutes);
    }
  }

  static String _labelForOffset(int diffMinutes) {
    switch (diffMinutes) {
      case 5:
        return '5 mins before';
      case 10:
        return '10 mins before';
      case 30:
        return '30 mins before';
      default:
        return 'On Time';
    }
  }

  String _errorMessage(ApiErrorResponse error) {
    final display = error.displayMessage;
    return display.isEmpty ? 'Operation failed. Please try again.' : display;
  }

  void _showSnackbar(String title, String message) {
    if (Get.testMode || Get.context == null) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}
