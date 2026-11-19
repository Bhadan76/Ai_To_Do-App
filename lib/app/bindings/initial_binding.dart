import 'package:get/get.dart';
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/tasks/presentation/controllers/task_controller.dart';
import '../../features/calendar/presentation/controllers/calendar_controller.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/ai_assistant/presentation/controllers/ai_controller.dart';
import '../../features/statistics/presentation/controllers/statistics_controller.dart';
import '../theme/app_theme.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ThemeController>(ThemeController(), permanent: true);
    Get.put<OnboardingController>(OnboardingController(),permanent: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<TaskController>(() => TaskController(), fenix: true);
    Get.lazyPut<CalendarController>(() => CalendarController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<AIController>(() => AIController(), fenix: true);
    Get.lazyPut<StatisticsController>(() => StatisticsController(), fenix: true);
  }
}
