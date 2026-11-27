import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/api/api_diagnostics.dart';
import '../../../../core/api/api_error_response.dart';
import '../../data/models/daily_plan_model.dart';
import '../../domain/repositories/ai_repository.dart';
import '../../domain/usecases/ai_usecases.dart';
import '../../../tasks/domain/usecases/task_usecases.dart';
import '../../../tasks/domain/models/task.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  AITaskProposal? taskProposal;
  final RxBool isConfirmed;
  final RxBool isCancelled;
  final RxBool isCreating;
  final RxString creationError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.taskProposal,
  })  : isConfirmed = false.obs,
        isCancelled = false.obs,
        isCreating = false.obs,
        creationError = ''.obs;
}

class AIController extends GetxController {
  AIController({
    GenerateDailyPlanUseCase? generateDailyPlanUseCase,
    GeneratePlanUseCase? generatePlanUseCase,
    PlanDayUseCase? planDayUseCase,
    this.createConversationUseCase,
    this.getConversationsUseCase,
    this.getConversationUseCase,
    this.sendMessageUseCase,
    this.deleteConversationUseCase,
    this.createTaskUseCase,
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
  final CreateConversationUseCase? createConversationUseCase;
  final GetConversationsUseCase? getConversationsUseCase;
  final GetConversationUseCase? getConversationUseCase;
  final SendMessageUseCase? sendMessageUseCase;
  final DeleteConversationUseCase? deleteConversationUseCase;
  final dynamic createTaskUseCase;

  // ── Chat state (AI Assistant conversation) ───────────────────────
  final messageController = TextEditingController();
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;
  final RxBool isSending = false.obs;
  final RxString errorMessage = ''.obs;

  final ScrollController scrollController = ScrollController();

  // ── Conversation history state ────────────────────────────────────
  final RxList<AIChatConversation> conversations = <AIChatConversation>[].obs;
  final RxBool isLoadingConversations = false.obs;
  final RxString conversationsError = ''.obs;

  final Rxn<AIChatConversation> currentConversation = Rxn<AIChatConversation>();
  final RxString _currentConversationId = ''.obs;
  RxString get currentConversationId => _currentConversationId;
  set currentConversationId(dynamic value) {
    if (value is RxString) {
      _currentConversationId.value = value.value;
    } else {
      _currentConversationId.value = value?.toString() ?? '';
    }
  }

  final RxBool isSwitchingConversation = false.obs;
  final RxBool isDeletingConversation = false.obs;

  String? get activeConversationId =>
      currentConversationId.value.isEmpty ? null : currentConversationId.value;
  set activeConversationId(String? value) =>
      currentConversationId.value = value ?? '';

  // ── Aliases for alternate naming conventions ──────────────────────
  RxList<AIChatConversation> get conversationHistory => conversations;
  RxBool get isHistoryLoading => isLoadingConversations;
  RxBool get isLoadingHistory => isLoadingConversations;
  RxString get historyError => conversationsError;
  RxString get historyErrorMessage => conversationsError;
  RxBool get isLoadingConversation => isSwitchingConversation;
  RxBool get isConversationLoading => isSwitchingConversation;
  RxBool get isSwitching => isSwitchingConversation;
  Rxn<AIChatConversation> get currentConversationMetadata =>
      currentConversation;
  String? get currentConversationIdValue => activeConversationId;

  String? _lastUserText;
  int _conversationsLoadRequestId = 0;
  int _conversationSwitchRequestId = 0;
  int _deleteRequestId = 0;

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

  /// Maximum characters accepted for a single AI chat message.
  static const int maxChatMessageLength = 4000;

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (isSending.value) return;
    if (trimmed.length > maxChatMessageLength) {
      errorMessage.value =
          'Message is too long. Please keep it under $maxChatMessageLength characters.';
      return;
    }

    isSending.value = true;
    isTyping.value = true;
    errorMessage.value = '';
    messageController.clear();
    _scrollToBottom();

    messages.add(ChatMessage(text: trimmed, isUser: true, time: _currentTime));
    _lastUserText = trimmed;

    try {
      var conversationId = activeConversationId;
      if (conversationId == null || conversationId.isEmpty) {
        final conversation = await _createConversation();
        final newId = conversation.id;
        if (newId == null || newId.isEmpty) {
          throw const AIException(
            'AI assistant did not return a conversation.',
          );
        }
        conversationId = newId;
        activeConversationId = newId;
        currentConversation.value = conversation;
      }

      final response = await _sendMessage(conversationId, trimmed);

      if (response.conversation.id != null &&
          response.conversation.id!.isNotEmpty) {
        activeConversationId = response.conversation.id;
      }
      currentConversation.value = response.conversation;

      final assistantText = response.assistantMessage.content.trim();
      final proposal = response.taskProposal;
      final displayText = assistantText.isNotEmpty
          ? assistantText
          : (proposal?.message ?? '');
      if (displayText.isNotEmpty || proposal != null) {
        messages.add(
          ChatMessage(
            text: displayText.isNotEmpty
                ? displayText
                : 'I prepared a task for you. Please review it before creating.',
            isUser: false,
            time: _formatTime(response.assistantMessage.createdAt),
            taskProposal: proposal,
          ),
        );
      }
    } catch (e) {
      // The assistant reply was not generated: drop the optimistic user
      // message so the conversation history stays consistent.
      if (messages.isNotEmpty && messages.last.isUser) {
        messages.removeAt(messages.length - 1);
      }
      final friendlyMessage = _friendlyError(e);
      errorMessage.value = friendlyMessage;
      _showSnackbar('AI Assistant', friendlyMessage);
    } finally {
      isSending.value = false;
      isTyping.value = false;
    }
  }

  Future<void> sendQuickAction(String action) => sendMessage(action);

  Future<void> sendSuggestedPrompt(String prompt) => sendMessage(prompt);

  Future<void> retryMessage() async {
    final text = _lastUserText;
    if (text == null || text.trim().isEmpty) return;
    await sendMessage(text);
  }

  void startNewConversation() {
    messages.clear();
    messageController.clear();
    activeConversationId = null;
    currentConversation.value = null;
    errorMessage.value = '';
    isTyping.value = false;
    isSending.value = false;
    isSwitchingConversation.value = false;
    _lastUserText = null;
  }

  // ── Conversation history methods ──────────────────────────────────

  Future<void> loadConversations({int page = 1, int pageSize = 20}) =>
      fetchConversations(page: page, pageSize: pageSize);

  Future<void> fetchConversations({int page = 1, int pageSize = 20}) async {
    final requestId = ++_conversationsLoadRequestId;
    isLoadingConversations.value = true;
    conversationsError.value = '';
    try {
      final result = await _getConversations(page: page, pageSize: pageSize);
      if (requestId != _conversationsLoadRequestId) return;
      conversations.assignAll(result);
    } catch (e) {
      if (requestId != _conversationsLoadRequestId) return;
      conversationsError.value = _friendlyError(e);
    } finally {
      if (requestId == _conversationsLoadRequestId) {
        isLoadingConversations.value = false;
      }
    }
  }

  Future<void> refreshConversations({int page = 1, int pageSize = 20}) =>
      fetchConversations(page: page, pageSize: pageSize);

  Future<void> refreshHistory({int page = 1, int pageSize = 20}) =>
      fetchConversations(page: page, pageSize: pageSize);

  Future<void> loadConversationHistory({int page = 1, int pageSize = 20}) =>
      fetchConversations(page: page, pageSize: pageSize);

  Future<void> selectConversation(String conversationId) =>
      loadConversation(conversationId);

  Future<void> openConversation(String conversationId) =>
      loadConversation(conversationId);

  Future<void> loadConversation(String conversationId) async {
    if (conversationId.trim().isEmpty) return;
    final id = conversationId.trim();
    final requestId = ++_conversationSwitchRequestId;
    isSwitchingConversation.value = true;
    try {
      final detail = await _getConversation(id);
      if (requestId != _conversationSwitchRequestId) return;
      currentConversationId.value = id;
      final conversation = detail.conversation;
      currentConversation.value =
          (conversation.id == null || conversation.id!.isEmpty)
          ? AIChatConversation(
              id: id,
              title: conversation.title,
              createdAt: conversation.createdAt,
              updatedAt: conversation.updatedAt,
            )
          : conversation;

      final sorted = List<AIChatMessage>.from(detail.messages);
      sorted.sort((a, b) {
        final aTime = a.createdAt;
        final bTime = b.createdAt;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });

      messages.assignAll(
        sorted.map(
          (m) => ChatMessage(
            text: m.content,
            isUser: m.isUser,
            time: _formatTime(m.createdAt),
          ),
        ),
      );
      _lastUserText = null;
      errorMessage.value = '';
    } catch (e) {
      if (requestId != _conversationSwitchRequestId) return;
      errorMessage.value = _friendlyError(e);
    } finally {
      if (requestId == _conversationSwitchRequestId) {
        isSwitchingConversation.value = false;
      }
    }
  }

  Future<void> deleteConversation(String conversationId) =>
      removeConversation(conversationId);

  Future<void> removeConversation(String conversationId) async {
    final id = conversationId.trim();
    if (id.isEmpty) return;
    final requestId = ++_deleteRequestId;
    isDeletingConversation.value = true;
    try {
      await _deleteConversation(id);
      if (requestId != _deleteRequestId) return;
      conversations.removeWhere((c) => c.id == id);
      if (currentConversationId.value == id) {
        startNewConversation();
      }
      await fetchConversations();
    } catch (e) {
      if (requestId != _deleteRequestId) return;
      conversationsError.value = _friendlyError(e);
      errorMessage.value = _friendlyError(e);
    } finally {
      if (requestId == _deleteRequestId) {
        isDeletingConversation.value = false;
      }
    }
  }

  static String conversationTitle(AIChatConversation conversation) {
    final title = conversation.title?.trim();
    if (title == null || title.isEmpty) {
      return 'Untitled conversation';
    }
    return title;
  }

  static String displayConversationTitle(AIChatConversation conversation) =>
      conversationTitle(conversation);

  bool get canSendMessages =>
      !isSending.value &&
      messageController.text.trim().isNotEmpty &&
      messageController.text.trim().length <= maxChatMessageLength;

  Future<void> confirmTaskProposal(ChatMessage message) async {
    final proposal = message.taskProposal;
    if (proposal == null) return;
    if (message.isConfirmed.value ||
        message.isCancelled.value ||
        message.isCreating.value) {
      return;
    }
    if (proposal.title.trim().isEmpty) {
      message.creationError.value = 'Task title is required.';
      return;
    }

    message.isCreating.value = true;
    message.creationError.value = '';
    try {
      final dueDate = _proposalDueDate(proposal);
      final created = await _createTaskFromProposal(proposal, dueDate);
      message.isConfirmed.value = true;
      message.taskProposal = null;
      messages.add(
        ChatMessage(
          text: 'Task created successfully: ${created.title}',
          isUser: false,
          time: _currentTime,
        ),
      );
      _scrollToBottom();
    } catch (e) {
      message.creationError.value = _friendlyError(e);
    } finally {
      message.isCreating.value = false;
    }
  }

  void cancelTaskProposal(ChatMessage message) {
    if (message.isConfirmed.value) return;
    message.isCancelled.value = true;
    message.taskProposal = null;
  }

  Future<TaskEntity> _createTaskFromProposal(
    AITaskProposal proposal,
    String? dueDate,
  ) async {
    final useCase = createTaskUseCase ?? Get.find<CreateTaskUseCase>();
    return await (useCase as CreateTaskUseCase).call(
      title: proposal.title.trim(),
      description: proposal.description,
      dueDate: dueDate,
      categoryId: proposal.categoryId,
      priority: proposal.priority,
    );
  }

  String? _proposalDueDate(AITaskProposal proposal) {
    final date = proposal.dueDate?.trim();
    if (date == null || date.isEmpty) return null;
    String value = date;
    if (!value.contains('T')) {
      final time = proposal.dueTime?.trim();
      if (time != null && time.isNotEmpty) {
        value = '$value' 'T$time:00';
      } else {
        value = '$value' 'T00:00:00';
      }
    }
    if (value.endsWith('Z') ||
        RegExp(r'[+-]\d{2}:\d{2}$').hasMatch(value)) {
      return value;
    }
    return '${value}Z';
  }

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

  String _formatTime(DateTime? createdAt) {
    if (createdAt == null) return _currentTime;
    final h = createdAt.hour > 12 ? createdAt.hour - 12 : createdAt.hour;
    final m = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String _friendlyError(Object error) {
    if (error is ApiErrorResponse) {
      if (error.statusCode == 503) {
        return 'The AI assistant is temporarily unavailable. Please try again in a moment.';
      }
      final message = error.displayMessage;
      if (message.isNotEmpty) return message;
      return 'I could not reach the AI assistant just now. Please try again.';
    }
    if (error is AIException) {
      if (error.message.isNotEmpty) return error.message;
    }
    return 'I could not reach the AI assistant just now. Please try again.';
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

  // ── Smart Daily Planner state ─────────────────────────────────────
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString availableStartTime = '09:00'.obs;
  final RxString availableEndTime = '17:00'.obs;

  final RxBool isLoading = false.obs;
  final Rxn<DailyPlan> dailyPlan = Rxn<DailyPlan>();

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

    ApiDiagnostics.plannerTriggered(
      date: planningDate,
      availableStartTime: availableStartTime.value,
      availableEndTime: availableEndTime.value,
    );

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
  Future<DailyPlan?> refreshPlan() => generatePlan();
  Future<DailyPlan?> regeneratePlan() => generatePlan();
  void reviewPlan() {
    if (dailyPlan.value != null && Get.context != null) {
      Get.snackbar(
        'Plan Review',
        'Your daily plan looks well-balanced!',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ── Chat helpers ─────────────────────────────────────────────────

  Future<AIChatConversation> _createConversation() async {
    if (createConversationUseCase != null) {
      return createConversationUseCase!.call(title: 'New Conversation');
    }
    return _repository!.createConversation(title: 'New Conversation');
  }

  Future<SendAIMessageResponse> _sendMessage(
    String conversationId,
    String content,
  ) async {
    if (sendMessageUseCase != null) {
      return sendMessageUseCase!.call(
        conversationId: conversationId,
        content: content,
      );
    }
    return _repository!.sendMessage(conversationId, content);
  }

  Future<List<AIChatConversation>> _getConversations({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (getConversationsUseCase != null) {
      return getConversationsUseCase!.call(page: page, pageSize: pageSize);
    }
    if (_repository != null) {
      return _repository.getConversations(page: page, pageSize: pageSize);
    }
    throw const AIException('AI repository is not configured.');
  }

  Future<AIChatConversationDetail> _getConversation(
    String conversationId,
  ) async {
    if (getConversationUseCase != null) {
      return getConversationUseCase!.call(conversationId);
    }
    if (_repository != null) {
      return _repository.getConversation(conversationId);
    }
    throw const AIException('AI repository is not configured.');
  }

  Future<void> _deleteConversation(String conversationId) async {
    if (deleteConversationUseCase != null) {
      return deleteConversationUseCase!.call(conversationId);
    }
    if (_repository != null) {
      return _repository.deleteConversation(conversationId);
    }
    throw const AIException('AI repository is not configured.');
  }

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
