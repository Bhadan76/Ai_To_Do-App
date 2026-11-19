import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app/routes/route_names.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final int totalPages = 3;

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      goToLogin();
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void skipOnboarding() => goToLogin();

  void goToLogin() => Get.offAllNamed(RouteNames.login);

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
