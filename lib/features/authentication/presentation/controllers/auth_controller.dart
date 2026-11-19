import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../app/routes/route_names.dart';

class AuthController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void login() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
    Get.offAllNamed(RouteNames.home);
  }

  void loginWithGoogle() => Get.offAllNamed(RouteNames.home);
  void loginWithFacebook() => Get.offAllNamed(RouteNames.home);

  void goToRegister() => Get.toNamed(RouteNames.register);
  void goToForgotPassword() {}

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
