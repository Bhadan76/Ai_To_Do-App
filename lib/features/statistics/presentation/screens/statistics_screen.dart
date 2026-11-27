import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../controllers/statistics_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class StatisticsScreen extends StatelessWidget {
  final bool embedInNav;
  const StatisticsScreen({super.key, this.embedInNav = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StatisticsController>();

    return Scaffold(
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
          Obx(
            () => Card(
              child: ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                ),
                title: Text('${controller.completed} tasks completed'),
                subtitle: Text(
                  '${controller.total} total, '
                  '${(controller.progress * 100).round()}% complete',
                ),
              ),
            ),
          ),
          Obx(
            () => Card(
              child: ListTile(
                leading: Icon(
                  Icons.local_fire_department_outlined,
                  color: Colors.orange,
                ),
                title: Text('${controller.pending} pending tasks'),
                subtitle: const Text('Complete them to keep moving forward!'),
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: () => Get.toNamed(RouteNames.aiAssistant),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Get smart suggestions'),
          ),
        ],
      ),
      bottomNavigationBar: embedInNav
          ? null
          : AppBottomNavBar(
              currentIndex: 3,
              onTap: (index) {
                if (Get.isRegistered<HomeController>()) {
                  Get.find<HomeController>().changeNavIndex(index);
                }
              },
            ),
    );
  }
}
