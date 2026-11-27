// ignore_for_file: prefer_initializing_formals, unused_field

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/api/token_storage.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../categories/presentation/controllers/category_controller.dart';
import '../../../tasks/presentation/controllers/task_controller.dart';
import '../../../tasks/domain/repositories/task_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final TokenStorage _tokenStorage;

  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
    required TokenStorage tokenStorage,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _restoreSessionUseCase = restoreSessionUseCase,
       _tokenStorage = tokenStorage;

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  // UI state
  final RxBool isPasswordVisible = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  /// Whether a valid session is currently stored (access token present).
  final RxBool isLoggedIn = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Attempt to restore a previous session.
  /// Returns true if a valid session exists.
  Future<bool> restoreSession() async {
    try {
      final session = await _restoreSessionUseCase.call();
      final hasSession = session != null;
      isLoggedIn.value = hasSession;
      if (hasSession) {
        // Do not block session restore on best-effort notification registration.
        registerNotificationToken();
        _refreshProfileSafely();
      }
      return hasSession;
    } catch (_) {
      isLoggedIn.value = false;
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
      _clearUserCaches();
      await _loginUseCase.call(email: email, password: password);
      isLoading.value = false;
      isLoggedIn.value = true;
      await registerNotificationToken();
      _refreshProfileSafely();
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
      _clearUserCaches();
      await _registerUseCase.call(name: name, email: email, password: password);
      isLoading.value = false;
      isLoggedIn.value = true;
      await registerNotificationToken();
      _refreshProfileSafely();
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
      // Unregister this device's FCM token before the session is cleared.
      // Failures here must never block the local logout.
      if (Get.isRegistered<NotificationController>()) {
        try {
          await Get.find<NotificationController>().unregisterToken();
        } catch (_) {
          // Ignore token-unregistration failures.
        }
      }
      await _logoutUseCase.call();
    } catch (_) {
      // Logout always clears local session even on error
    } finally {
      isLoggedIn.value = false;
      isLoading.value = false;
      _clearUserCaches();
      _safeNavigateToLogin();
    }
  }

  /// Registers the current device's FCM token with the backend after a
  /// successful login, registration, or session restore.
  ///
  /// Failures never block the auth flow itself.
  Future<void> registerNotificationToken() async {
    try {
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().registerToken();
      }
    } catch (_) {
      // Ignore: notifications are best-effort and must not fail auth.
    }
  }

  void _refreshProfileSafely() {
    try {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile();
      } else {
        final controller = Get.find<ProfileController>();
        controller.fetchProfile();
      }
    } catch (_) {
      // Profile refresh is best-effort and must not fail auth.
    }
  }

  void goToRegister() => Get.toNamed(RouteNames.register);
  void goToForgotPassword() {}

  /// Navigate to home safely (handles test environment without binding).
  void _clearUserCaches() {
    try {
      if (Get.isRegistered<TaskController>()) {
        Get.find<TaskController>().clearCache();
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<CategoryController>()) {
        Get.find<CategoryController>().clearCache();
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().clearCache();
      }
    } catch (_) {}
    try {
      Get.find<TaskRepository>().clearCache();
    } catch (_) {}
    try {
      Get.find<CategoryRepository>().clearCache();
    } catch (_) {}
    try {
      Get.find<ProfileRepository>().clearCache();
    } catch (_) {}
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().tasks.clear();
      }
    } catch (_) {}
  }

  void _safeNavigateToHome() {
    try {
      Get.offAllNamed(RouteNames.home);
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().checkAndNavigatePendingTask();
      }
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
