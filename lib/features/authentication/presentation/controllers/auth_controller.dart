// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../app/routes/route_names.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _restoreSessionUseCase = restoreSessionUseCase;

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // UI state
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Attempt to restore a previous session.
  /// Returns true if a valid session exists.
  Future<bool> restoreSession() async {
    try {
      final session = await _restoreSessionUseCase.call();
      return session != null;
    } catch (_) {
      return false;
    }
  }

  /// Login with email and password.
  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _loginUseCase.call(email: email, password: password);
      isLoading.value = false;
      _safeNavigateToHome();
    } on AuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Register a new account.
  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields';
      return;
    }

    if (password.length < 12) {
      errorMessage.value = 'Password must be at least 12 characters';
      return;
    }

    if (!password.contains(RegExp(r'[a-z]')) ||
        !password.contains(RegExp(r'[A-Z]')) ||
        !password.contains(RegExp(r'\d'))) {
      errorMessage.value =
          'Password must include lowercase, uppercase, and a number';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _registerUseCase.call(name: name, email: email, password: password);
      isLoading.value = false;
      _safeNavigateToHome();
    } on AuthException catch (e) {
      isLoading.value = false;
      errorMessage.value = e.message;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// Logout and clear session.
  Future<void> logout() async {
    isLoading.value = true;
    try {
      await _logoutUseCase.call();
    } catch (_) {
      // Logout always clears local session even on error
    } finally {
      isLoading.value = false;
      _safeNavigateToLogin();
    }
  }

  void goToRegister() => Get.toNamed(RouteNames.register);
  void goToForgotPassword() {}

  /// Navigate to home safely (handles test environment without binding).
  void _safeNavigateToHome() {
    try {
      Get.offAllNamed(RouteNames.home);
    } catch (_) {
      // Navigation may fail in test environments
    }
  }

  /// Navigate to login safely (handles test environment without binding).
  void _safeNavigateToLogin() {
    try {
      Get.offAllNamed(RouteNames.login);
    } catch (_) {
      // Navigation may fail in test environments
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}
