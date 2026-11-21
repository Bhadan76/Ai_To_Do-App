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
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryController = Get.find<CategoryController>();
    return Scaffold(
      body: SafeArea(
        child: _buildBody(context, categoryController),
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

  Widget _buildBody(BuildContext context, CategoryController categoryController) {
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
                    Get.toNamed(RouteNames.taskDetails, arguments: task),
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
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildAddCategoryCard(context),
                ...categoryController.categories
                    .take(5)
                    .map(
                      (cat) => CategoryCard(
                        category: cat.name,
                        onTap: () => Get.toNamed(RouteNames.categories),
                      ),
                    ),
              ],
            ),
          const SizedBox(height: AppSizes.md),
        ],
      ),
    );
  }

  Widget _buildAddCategoryCard(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Get.toNamed(RouteNames.categories),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
