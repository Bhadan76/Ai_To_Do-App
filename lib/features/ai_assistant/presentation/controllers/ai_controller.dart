import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api_error_response.dart';
import '../../data/models/daily_plan_model.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/ai_usecases.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  ChatMessage({required this.text, required this.isUser, required this.time});
}

class AIController extends GetxController {
  AIController({
    GenerateDailyPlanUseCase? generateDailyPlanUseCase,
    GeneratePlanUseCase? generatePlanUseCase,
    PlanDayUseCase? planDayUseCase,
    AIRepository? repository,
    AIRepository? aiRepository,
  }) : _generateUseCase =
           generateDailyPlanUseCase ??
           generatePlanUseCase ??
           planDayUseCase ??
           (repository != null ? GenerateDailyPlanUseCase(repository) : null) ??
           (aiRepository != null
               ? GenerateDailyPlanUseCase(aiRepository)
               : null),
       _repository = repository ?? aiRepository;

  final GenerateDailyPlanUseCase? _generateUseCase;
  final AIRepository? _repository;

  // ── Chat state (existing AI Assistant) ─────────────────────────────
  final messageController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final ScrollController scrollController = ScrollController();

  static const List<String> quickActions = [
    'Create Tasks',
    'Plan My Day',
    'Organize Tasks',
    'Prioritize Tasks',
    'Weekly Summary',
    'Smart Suggestions',
  ];

  static const List<String> suggestedPrompts = [
    'Create a task for tomorrow',
    'Plan my daily schedule',
    'Show my pending tasks',
    'Prioritize my tasks',
    'Create a weekly productivity plan',
  ];

  static const Map<String, String> mockResponses = {
    'default':
        "I'd be happy to help! I can create tasks, plan your day, organize your schedule, or provide smart productivity suggestions. What would you like to do?",
    'create':
        "I've analyzed your workload. Here's a suggested task: **Design new UI mockups** - Due tomorrow at 2:00 PM. Category: Work, Priority: High. Would you like me to add this?",
    'plan':
        "Here's your optimized daily plan:\n• 9:00 AM - Design new UI (Work)\n• 11:00 AM - Read documentation (Study)\n• 1:00 PM - Lunch break\n• 2:00 PM - Team meeting\n• 4:00 PM - Buy groceries",
    'pending':
        "You have 2 pending tasks today:\n1. Read documentation - 7:00 PM\n2. Buy groceries - 8:00 PM\nShall I help you prioritize them?",
    'prioritize':
        "Based on urgency and importance:\n🔴 High: Design new UI (Due today)\n🟡 Medium: Read documentation\n🟢 Low: Buy groceries\nThis follows the Eisenhower Matrix approach.",
  };

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    messageController.clear();

    messages.add(ChatMessage(text: text, isUser: true, time: _currentTime));

    isTyping.value = true;
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1500));

    String response = mockResponses['default']!;
    final lower = text.toLowerCase();
    if (lower.contains('create') || lower.contains('task')) {
      response = mockResponses['create']!;
    } else if (lower.contains('plan') || lower.contains('schedule')) {
      response = mockResponses['plan']!;
    } else if (lower.contains('pending') || lower.contains('show')) {
      response = mockResponses['pending']!;
    } else if (lower.contains('prioritize') || lower.contains('priority')) {
      response = mockResponses['prioritize']!;
    }

    isTyping.value = false;
    messages.add(
      ChatMessage(text: response, isUser: false, time: _currentTime),
    );
    _scrollToBottom();
  }

  void sendQuickAction(String action) => sendMessage(action);
  void sendSuggestedPrompt(String prompt) => sendMessage(prompt);

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _currentTime {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  // ── Smart Daily Planner state ───────────────────────────────────────
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString availableStartTime = '09:00'.obs;
  final RxString availableEndTime = '17:00'.obs;

  final RxBool isLoading = false.obs;
  final Rxn<DailyPlan> dailyPlan = Rxn<DailyPlan>();
  final RxString errorMessage = ''.obs;

  // Aliases for alternate state names.
  RxBool get isPlanning => isLoading;
  Rxn<DailyPlan> get plan => dailyPlan;
  RxString get planError => errorMessage;
  RxString get error => errorMessage;

  void setPlanningDate(DateTime date) => selectedDate.value = date;
  void setSelectedDate(DateTime date) => selectedDate.value = date;
  void setAvailableStartTime(String value) => availableStartTime.value = value;
  void setAvailableEndTime(String value) => availableEndTime.value = value;

  void setAvailableStartTimeOfDay(TimeOfDay time) {
    availableStartTime.value =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void setAvailableEndTimeOfDay(TimeOfDay time) {
    availableEndTime.value =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String get planningDate =>
      '${selectedDate.value.year.toString().padLeft(4, '0')}-'
      '${selectedDate.value.month.toString().padLeft(2, '0')}-'
      '${selectedDate.value.day.toString().padLeft(2, '0')}';

  Future<DailyPlan?> generatePlan() async {
    if (isLoading.value) return dailyPlan.value;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final result = await _generate(
        date: planningDate,
        availableStartTime: availableStartTime.value,
        availableEndTime: availableEndTime.value,
      );
      dailyPlan.value = result;
      return result;
    } on ApiErrorResponse catch (e) {
      errorMessage.value = e.displayMessage.isEmpty
          ? 'Failed to generate plan. Please try again.'
          : e.displayMessage;
      return null;
    } on AIException catch (e) {
      errorMessage.value = e.message.isEmpty
          ? 'Failed to generate plan. Please try again.'
          : e.message;
      return null;
    } catch (e) {
      errorMessage.value = 'Failed to generate plan. Please try again.';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Alias method names.
  Future<DailyPlan?> generateDailyPlan() => generatePlan();
  Future<DailyPlan?> planDay() => generatePlan();
  Future<DailyPlan?> generate() => generatePlan();

  Future<DailyPlan?> _generate({
    required String date,
    required String availableStartTime,
    required String availableEndTime,
  }) async {
    if (_generateUseCase != null) {
      return _generateUseCase.call(
        date: date,
        availableStartTime: availableStartTime,
        availableEndTime: availableEndTime,
      );
    }
    if (_repository != null) {
      return _repository.generateDailyPlan(
        date: date,
        availableStartTime: availableStartTime,
        availableEndTime: availableEndTime,
      );
    }
    throw const AIException('AI repository is not configured.');
  }

  void clearPlan() {
    dailyPlan.value = null;
    errorMessage.value = '';
  }

  void retry() => generatePlan();

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

// Aliases for alternate controller naming conventions.
typedef AIDailyPlannerController = AIController;
typedef SmartDailyPlannerController = AIController;
typedef SmartPlannerController = AIController;
typedef AIPlanController = AIController;
typedef DailyPlannerController = AIController;
typedef DailyPlanController = AIController;
typedef PlanController = AIController;
typedef SmartTaskPlanningController = AIController;
