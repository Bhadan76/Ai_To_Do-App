import 'package:get/get.dart';
import '../../features/onboarding/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/tasks/presentation/screens/add_task_screen.dart';
import '../../features/tasks/presentation/screens/task_details_screen.dart';
import '../../features/tasks/presentation/screens/all_tasks_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_task_generation_screen.dart';
import 'route_names.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(name: RouteNames.splash, page: () => const SplashScreen()),
    GetPage(name: RouteNames.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: RouteNames.login, page: () => const LoginScreen()),
    GetPage(name: RouteNames.register, page: () => const RegisterScreen()),
    GetPage(name: RouteNames.home, page: () => const HomeScreen()),
    GetPage(name: RouteNames.addTask, page: () => const AddTaskScreen()),
    GetPage(
      name: RouteNames.taskDetails,
      page: () => const TaskDetailsScreen(),
    ),
    GetPage(name: RouteNames.allTasks, page: () => const AllTasksScreen()),
    GetPage(
      name: RouteNames.notifications,
      page: () => const NotificationScreen(),
    ),
    GetPage(name: RouteNames.calendar, page: () => const CalendarScreen()),
    GetPage(name: RouteNames.categories, page: () => const AllTasksScreen()),
    GetPage(name: RouteNames.profile, page: () => const ProfileScreen()),
    GetPage(name: RouteNames.statistics, page: () => const StatisticsScreen()),
    GetPage(
      name: RouteNames.aiAssistant,
      page: () => const AIAssistantScreen(),
    ),
    GetPage(
      name: RouteNames.aiTaskGeneration,
      page: () => const AITaskGenerationScreen(),
    ),
  ];
}
