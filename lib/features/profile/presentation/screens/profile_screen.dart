import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../../shared/widgets/profile_menu_item.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_metric.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileController get controller => Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    if (!Get.testMode &&
        controller.profile.value == null &&
        !controller.isLoading.value) {
      controller.fetchProfile();
    } else if (!Get.testMode) {
      controller.loadProfileImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Obx(() => _buildprofileCard(context, controller)),
          const SizedBox(height: 14),
          Obx(
            () => SwitchListTile(
              value: themeController.isDarkMode.value,
              onChanged: (_) => themeController.toggleTheme(),
              title: const Text('Dark appearance'),
              secondary: const Icon(
                Icons.dark_mode_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
          ProfileMenuItem(
            icon: Icons.edit_rounded,
            title: 'Edit Profile',
            onTap: () => controller.goToEditProfile(),
          ),
          ProfileMenuItem(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            onTap: () => Get.toNamed(RouteNames.notifications),
          ),
          const ProfileMenuItem(
            icon: Icons.language_rounded,
            title: 'Language',
          ),
          const ProfileMenuItem(
            icon: Icons.info_outline_rounded,
            title: 'About App',
          ),
          const ProfileMenuItem(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
          ),
          ListTile(
            leading: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
            ),
            title: const Text('AI Assistant'),
            onTap: () => Get.toNamed(RouteNames.aiAssistant),
          ),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: AppColors.errorRed,
            ),
            title: const Text('Logout'),
            onTap: () => controller.logout(),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          if (index == 0) Get.offAllNamed(RouteNames.home);
          if (index == 1) Get.offNamed(RouteNames.calendar);
          if (index == 2) Get.toNamed(RouteNames.addTask);
          if (index == 3) Get.offNamed(RouteNames.statistics);
          if (index == 4) Get.offNamed(RouteNames.profile);
        },
      ),
    );
  }

  Widget _buildProfileMetrics() {
    if (!Get.isRegistered<HomeController>()) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ProfileMetric(value: '0', label: 'Tasks'),
          ProfileMetric(value: '0', label: 'Completed'),
          ProfileMetric(value: '0%', label: 'Progress'),
        ],
      );
    }

    final homeController = Get.find<HomeController>();
    return Obx(() {
      final total = homeController.totalTasks;
      final completed = homeController.completedTasks;
      final progress = homeController.progressPercent;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ProfileMetric(value: '$total', label: 'Tasks'),
          ProfileMetric(value: '$completed', label: 'Completed'),
          ProfileMetric(value: '$progress%', label: 'Progress'),
        ],
      );
    });
  }

  Widget _buildprofileCard(BuildContext context, ProfileController controller) {
    final p = controller.profile.value;
    final name = p?.name ?? 'User';
    final email = p?.email ?? '';
    final avatar = p?.avatar;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Obx(() {
              final localPath = controller.profileImagePath.value;
              final hasLocalImage =
                  localPath.isNotEmpty && File(localPath).existsSync();
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppColors.lightPurple,
                    backgroundImage: hasLocalImage
                        ? FileImage(File(localPath))
                        : (avatar != null && avatar.isNotEmpty)
                        ? NetworkImage(avatar)
                        : null,
                    child:
                        (!hasLocalImage && (avatar == null || avatar.isEmpty))
                        ? const Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: controller.pickProfileImage,
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(Icons.add, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            if (email.isNotEmpty)
              Text(
                email,
                style: const TextStyle(color: AppColors.secondaryText),
              ),
            if (controller.isLoading.value) ...[
              const SizedBox(height: 8),
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
            if (controller.errorMessage.value.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                controller.errorMessage.value,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ],
            const SizedBox(height: 18),
            _buildProfileMetrics(),
          ],
        ),
      ),
    );
  }
}
