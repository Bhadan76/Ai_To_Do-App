import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

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
          for (final entry in [
            ('Design new UI', '9:00 AM'),
            ('Read documentation', '7:00 PM'),
            ('Buy groceries', '8:00 PM'),
          ])
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: AppColors.primary,
                ),
                title: Text(entry.$1),
                subtitle: Text(entry.$2),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Get.offAllNamed(RouteNames.home);
          if (index == 1) Get.offNamed(RouteNames.calendar);
          if (index == 2) Get.toNamed(RouteNames.addTask);
          if (index == 3) Get.offNamed(RouteNames.statistics);
          if (index == 4) Get.offNamed(RouteNames.profile);
        },
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => Get.toNamed(RouteNames.addTask),
        child: const Icon(Icons.add),
      ),
    );
  }
}
