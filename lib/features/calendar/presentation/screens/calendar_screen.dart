import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/helpers.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../home/presentation/controllers/home_controller.dart';

class CalendarScreen extends StatefulWidget {
  final bool embedInNav;
  const CalendarScreen({super.key, this.embedInNav = false});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _month = DateTime.now();
  int _selectedDay = DateTime.now().day;

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => setState(
                          () =>
                              _month = DateTime(_month.year, _month.month - 1),
                        ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        '${_month.year} / ${_month.month.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(
                          () =>
                              _month = DateTime(_month.year, _month.month + 1),
                        ),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map(
                          (d) => SizedBox(
                            width: 34,
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: firstWeekday + days,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisExtent: 42,
                        ),
                    itemBuilder: (context, index) {
                      if (index < firstWeekday) return const SizedBox.shrink();
                      final day = index - firstWeekday + 1;
                      return InkWell(
                        onTap: () => setState(() => _selectedDay = day),
                        child: Center(
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: day == _selectedDay
                                ? AppColors.primary
                                : AppColors.white,
                            child: Text(
                              '$day',
                              style: TextStyle(
                                color: day == _selectedDay
                                    ? AppColors.white
                                    : AppColors.darkBackground,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            "Today's Tasks",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final tasksToday = Get.find<HomeController>().tasks
                .where((t) => AppHelpers.isDueToday(t.dueDate))
                .toList();
            if (tasksToday.isEmpty) {
              return const EmptyState(
                title: 'No tasks scheduled',
                message: 'You have no tasks due today.',
                icon: Icons.calendar_today_outlined,
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: tasksToday.length,
              itemBuilder: (context, index) {
                final task = tasksToday[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.radio_button_unchecked_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(task.title),
                    subtitle: Text(AppHelpers.formatDateTime(task.dueDate)),
                  ),
                );
              },
            );
          }),
        ],
      ),
      bottomNavigationBar: widget.embedInNav
          ? null
          : AppBottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (Get.isRegistered<HomeController>()) {
                  Get.find<HomeController>().changeNavIndex(index);
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'calendar_fab',
        shape: const CircleBorder(),
        onPressed: () => Get.toNamed(RouteNames.addTask),
        child: const Icon(Icons.add),
      ),
    );
  }
}
