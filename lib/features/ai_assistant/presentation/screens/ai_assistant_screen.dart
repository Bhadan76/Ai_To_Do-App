import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../domain/models/ai_chat.dart';
import '../controllers/ai_controller.dart';
import '../../../../../shared/widgets/ai_chat_bubble.dart';

class AIAssistantScreen extends GetView<AIController> {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    onDrawerChanged: (isOpened) {
      if (isOpened) {
        controller.loadConversations();
      }
    },
    appBar: AppBar(
      title: const Text('AI Assistant'),
      actions: [
        IconButton(
          tooltip: 'Task generation',
          onPressed: () => Get.toNamed(RouteNames.aiTaskGeneration),
          icon: const Icon(Icons.auto_awesome_rounded),
        ),
        IconButton(
          tooltip: 'Daily planner',
          onPressed: () => Get.toNamed(RouteNames.aiDailyPlanner),
          icon: const Icon(Icons.calendar_month_rounded),
        ),
        Builder(
          builder: (context) => IconButton(
            tooltip: 'Chat history',
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.history_rounded),
          ),
        ),
        IconButton(
          tooltip: 'New chat',
          onPressed: controller.startNewConversation,
          icon: const Icon(Icons.add_comment_rounded),
        ),
      ],
    ),
    drawer: const _ConversationHistoryDrawer(),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Obx(
              () =>
                  controller.errorMessage.value.isNotEmpty &&
                      controller.messages.isEmpty
                  ? EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not get AI response',
                      message: controller.errorMessage.value,
                      actionLabel: 'Retry',
                      onAction: () => controller.retryMessage(),
                    )
                  : controller.messages.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(18),
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
                        const SizedBox(height: 14),
                        Text(
                          'Hi Bhadan! 👋',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const Text(
                          "I'm your AI productivity assistant. How can I help you today?",
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: AIController.quickActions
                              .map(
                                (action) => ActionChip(
                                  label: Text(action),
                                  onPressed: () =>
                                      controller.sendQuickAction(action),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        ...AIController.suggestedPrompts.map(
                          (prompt) => ListTile(
                            leading: const Icon(
                              Icons.arrow_outward_rounded,
                              color: AppColors.primary,
                            ),
                            title: Text(prompt),
                            onTap: () => controller.sendSuggestedPrompt(prompt),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          controller.messages.length +
                          (controller.isTyping.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= controller.messages.length) {
                          return const ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.auto_awesome),
                            ),
                            title: Text('Thinking…'),
                          );
                        }
                        final message = controller.messages[index];
                        return Column(
                          crossAxisAlignment: message.isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            AIChatBubble(
                              text: message.text,
                              isUser: message.isUser,
                              time: message.time,
                            ),
                            if (!message.isUser && message.taskProposal != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  bottom: 8,
                                ),
                                child: _TaskProposalCard(
                                  message: message,
                                  controller: controller,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Get.snackbar(
                    'Attachment',
                    'Attachments are not available in this preview',
                  ),
                  icon: const Icon(Icons.attach_file_rounded),
                ),
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything…',
                      isDense: true,
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller.messageController,
                  builder: (context, value, _) {
                    return Obx(() {
                      final canSend =
                          !controller.isSending.value &&
                          value.text.trim().isNotEmpty &&
                          value.text.trim().length <=
                              AIController.maxChatMessageLength;
                      return IconButton(
                        onPressed: canSend
                            ? () => controller.sendMessage(value.text)
                            : null,
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppColors.primary,
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ConversationHistoryDrawer extends GetView<AIController> {
  const _ConversationHistoryDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.history_rounded, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Conversations',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Refresh conversations',
                    onPressed: controller.loadConversations,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: FilledButton.icon(
                onPressed: () {
                  controller.startNewConversation();
                  Get.back();
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('New Chat'),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingConversations.value &&
                    controller.conversations.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.conversationsError.value.isNotEmpty &&
                    controller.conversations.isEmpty) {
                  return EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load conversations',
                    message: controller.conversationsError.value,
                    actionLabel: 'Retry',
                    onAction: controller.loadConversations,
                  );
                }
                if (controller.conversations.isEmpty) {
                  return const EmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'No conversations yet',
                    message: 'Start a new chat to see it here.',
                  );
                }
                return ListView.builder(
                  itemCount: controller.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = controller.conversations[index];
                    final id = conversation.id ?? '';
                    final isSelected =
                        id.isNotEmpty &&
                        controller.currentConversationId.value == id;
                    return ListTile(
                      selected: isSelected,
                      leading: Icon(
                        isSelected
                            ? Icons.chat_rounded
                            : Icons.chat_bubble_outline_rounded,
                        color: isSelected ? AppColors.primary : null,
                      ),
                      title: Text(AIController.conversationTitle(conversation)),
                      subtitle: Text(
                        _formatDateTime(
                          conversation.updatedAt ?? conversation.createdAt,
                        ),
                      ),
                      trailing: IconButton(
                        tooltip: 'Delete conversation',
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () =>
                            _confirmDelete(context, controller, conversation),
                      ),
                      onTap: () {
                        Get.back();
                        if (id.isNotEmpty) {
                          controller.selectConversation(id);
                        }
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(DateTime? value) {
    if (value == null) return '';
    final local = value.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AIController controller,
    AIChatConversation conversation,
  ) async {
    final id = conversation.id;
    if (id == null || id.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete conversation?'),
        content: Text(
          'Delete "${AIController.conversationTitle(conversation)}"? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteConversation(id);
    }
  }
}

class _TaskProposalCard extends StatelessWidget {
  const _TaskProposalCard({required this.message, required this.controller});

  final ChatMessage message;
  final AIController controller;

  @override
  Widget build(BuildContext context) {
    final proposal = message.taskProposal;
    if (proposal == null) return const SizedBox.shrink();

    return Obx(() {
      final cancelled = message.isCancelled.value;
      final confirmed = message.isConfirmed.value;
      final creating = message.isCreating.value;
      final error = message.creationError.value;

      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task proposal',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _row('Title', proposal.title),
              if (proposal.description != null &&
                  proposal.description!.trim().isNotEmpty)
                _row('Description', proposal.description!),
              _row('Due date', proposal.dueDate ?? 'Not set'),
              _row('Due time', proposal.dueTime ?? 'Not set'),
              _row('Priority', proposal.priority),
              _row('Category', proposal.categoryId ?? 'None'),
              if (proposal.estimatedDurationMinutes != null)
                _row(
                  'Estimated duration',
                  '${proposal.estimatedDurationMinutes} minutes',
                ),
              const SizedBox(height: 8),
              if (cancelled)
                const Text('Cancelled', style: TextStyle(color: Colors.grey))
              else if (confirmed)
                const Text(
                  'Task created',
                  style: TextStyle(color: Colors.green),
                )
              else ...[
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                Row(
                  children: [
                    FilledButton(
                      onPressed: creating
                          ? null
                          : () => controller.confirmTaskProposal(message),
                      child: creating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirm & Create Task'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: creating
                          ? null
                          : () => controller.cancelTaskProposal(message),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  static Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
