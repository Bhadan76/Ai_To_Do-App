import 'package:get/get.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class ProfileController extends GetxController {
  final RxBool notificationsEnabled = true.obs;

  void toggleNotifications(bool val) => notificationsEnabled.value = val;

  void toggleTheme() {
    Get.find<ThemeController>().toggleTheme();
  }

  void logout() {
    Get.find<AuthController>().logout();
  }
}
