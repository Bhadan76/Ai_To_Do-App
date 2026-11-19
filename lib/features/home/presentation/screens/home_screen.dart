import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../../shared/widgets/category_card.dart';
import '../../../../../shared/widgets/stats_card.dart';
import '../../../../../core/widgets/task_card.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, Bhadan 👋',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Let's finish today's tasks!",
                          style: TextStyle(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed(RouteNames.aiAssistant),
                    icon: const Icon(Icons.notifications_none_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StatsCard(
                totalTasks: controller.totalTasks,
                completedTasks: controller.completedTasks,
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Today's Tasks",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.toNamed(RouteNames.taskDetails),
                    child: const Text('View All'),
                  ),
                ],
              ),
              ...controller.todayTasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskCard(
                    task: task,
                    onToggle: (_) => controller.toggleTaskComplete(task.id),
                    onTap: () =>
                        Get.toNamed(RouteNames.taskDetails, arguments: task),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Categories',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  CategoryCard(category: 'Work'),
                  CategoryCard(category: 'Personal'),
                  CategoryCard(category: 'Health'),
                  CategoryCard(category: 'Study'),
                ],
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          currentIndex: controller.selectedNavIndex.value,
          onTap: controller.changeNavIndex,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Get.toNamed(RouteNames.aiAssistant),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
      ),
    );
  }
}
