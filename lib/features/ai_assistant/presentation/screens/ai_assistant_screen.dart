import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/ai_controller.dart';
import '../../../../../shared/widgets/ai_chat_bubble.dart';

class AIAssistantScreen extends GetView<AIController> {
  const AIAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('AI Assistant'),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(RouteNames.aiTaskGeneration),
          icon: const Icon(Icons.auto_awesome_rounded),
        ),
        IconButton(
          onPressed: () => controller.messages.clear(),
          icon: const Icon(Icons.history_rounded),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Obx(
              () => controller.messages.isEmpty
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
                        return AIChatBubble(
                          text: message.text,
                          isUser: message.isUser,
                          time: message.time,
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
                IconButton(
                  onPressed: () =>
                      controller.sendMessage(controller.messageController.text),
                  icon: const Icon(
                    Icons.send_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
