import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../app/theme/app_theme.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../../shared/widgets/profile_menu_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildprofileCard(context),
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
          const ProfileMenuItem(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
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
            onTap: () => Get.offAllNamed(RouteNames.login),
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

  Widget _buildprofileCard(BuildContext context) {
    return Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.lightPurple,
                  child: Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bhadan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Text(
                  'bhadan@example.com',
                  style: TextStyle(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 18),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ProfileMetric(value: '24', label: 'Tasks'),
                    ProfileMetric(value: '18', label: 'Completed'),
                    ProfileMetric(value: '75%', label: 'Progress'),
                  ],
                ),
              ],
            ),
          ),
        );
  }
}

class ProfileMetric extends StatelessWidget {
  final String value;
  final String label;
  const ProfileMetric({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      Text(
        label,
        style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
      ),
    ],
  );
}
