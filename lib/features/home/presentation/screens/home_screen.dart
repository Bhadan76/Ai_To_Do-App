import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/widgets/task_card.dart';
import '../../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../../shared/widgets/category_card.dart';
import '../../../../../shared/widgets/stats_card.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeController get controller => Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<CategoryController>()) {
        final categoryController = Get.find<CategoryController>();
        if (categoryController.categories.isEmpty) {
          categoryController.loadCategories();
        }
      }
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        if (profileController.profile.value == null) {
          profileController.fetchProfile();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    return Scaffold(
      body: SafeArea(child: _buildBody(context, categoryController)),
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

  Widget _buildGreeting(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      return Text(
        'Hi 👋',
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      );
    }

    final profileController = Get.find<ProfileController>();
    return Obx(() {
      final profile = profileController.profile.value;
      final name = profile?.name.trim() ?? '';
      final greeting = name.isNotEmpty ? 'Hi, $name 👋' : 'Hi 👋';
      return Text(
        greeting,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      );
    });
  }

  Widget _buildNotificationButton() {
    if (!Get.isRegistered<NotificationController>()) {
      return IconButton(
        onPressed: () => Get.toNamed(RouteNames.notifications),
        icon: const Icon(Icons.notifications_none_rounded, size: 26),
      );
    }

    final notifController = Get.find<NotificationController>();
    return Obx(() {
      final count = notifController.unreadCount.value;
      return Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            onPressed: () => Get.toNamed(RouteNames.notifications),
            icon: const Icon(Icons.notifications_none_rounded, size: 26),
          ),
          if (count > 0)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.errorRed,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildBody(
    BuildContext context,
    CategoryController categoryController,
  ) {
    return Obx(
      () => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(context),
                    const SizedBox(height: 5),
                    const Text(
                      "Let's finish today's tasks!",
                      style: TextStyle(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              _buildNotificationButton(),
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(RouteNames.allTasks),
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
                    Get.toNamed(RouteNames.taskDetails, arguments: task.id),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Categories',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (categoryController.isLoading.value)
            const SizedBox(
              height: 70,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (categoryController.categories.isEmpty)
            const Text(
              'No categories found.',
              style: TextStyle(color: AppColors.secondaryText),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: categoryController.categories
                  .map(
                    (cat) => CategoryCard(
                      category: cat.name,
                      onTap: () =>
                          Get.toNamed(RouteNames.allTasks, arguments: cat.name),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }
}
