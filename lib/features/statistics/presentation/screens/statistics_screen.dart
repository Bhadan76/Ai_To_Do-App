import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Statistics'), centerTitle: true),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Text(
                  'Weekly progress',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    7,
                    (i) => Column(
                      children: [
                        Container(
                          width: 24,
                          height: 45.0 + (i * 11 % 78),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primarySecondary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Card(
          child: ListTile(
            leading: Icon(Icons.check_circle_outline, color: AppColors.primary),
            title: Text('18 tasks completed'),
            subtitle: Text('75% of your weekly goal'),
          ),
        ),
        const Card(
          child: ListTile(
            leading: Icon(
              Icons.local_fire_department_outlined,
              color: Colors.orange,
            ),
            title: Text('4 day streak'),
            subtitle: Text('Keep up the great work!'),
          ),
        ),
        FilledButton.icon(
          onPressed: () => Get.toNamed(RouteNames.aiAssistant),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Get smart suggestions'),
        ),
      ],
    ),
    bottomNavigationBar: AppBottomNavBar(
      currentIndex: 3,
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
