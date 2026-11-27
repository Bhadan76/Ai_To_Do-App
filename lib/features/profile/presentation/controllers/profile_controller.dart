// ignore_for_file: prefer_initializing_formals

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/api/api_error_response.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../data/datasources/profile_image_storage.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/profile_usecases.dart';

class ProfileController extends GetxController {
  ProfileController({
    GetProfileUseCase? getProfileUseCase,
    FetchProfileUseCase? fetchProfileUseCase,
    UpdateProfileUseCase? updateProfileUseCase,
    ProfileRepository? repository,
    ProfileRepository? profileRepository,
    ProfileImageStorage? imageStorage,
  }) : _getProfileUseCase =
           getProfileUseCase ??
           fetchProfileUseCase ??
           (repository != null ? GetProfileUseCase(repository) : null) ??
           (profileRepository != null
               ? GetProfileUseCase(profileRepository)
               : null),
       _updateProfileUseCase =
           updateProfileUseCase ??
           (repository != null ? UpdateProfileUseCase(repository) : null) ??
           (profileRepository != null
               ? UpdateProfileUseCase(profileRepository)
               : null),
       _repository = repository ?? profileRepository,
       _imageStorage = imageStorage ?? ProfileImageStorage();

  final GetProfileUseCase? _getProfileUseCase;
  final UpdateProfileUseCase? _updateProfileUseCase;
  final ProfileRepository? _repository;
  final ProfileImageStorage _imageStorage;

  // Text controllers for the edit form.
  final nameController = TextEditingController();

  // UI state.
  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final Rx<ProfileEntity?> profile = Rx<ProfileEntity?>(null);
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;
  final RxString profileImagePath = ''.obs;

  // In-memory cache metadata.
  DateTime? _cachedAt;
  Future<void>? _fetchInFlight;
  static const Duration _cacheTtl = Duration(minutes: 5);

  final ImagePicker _picker = ImagePicker();

  bool get hasProfile => profile.value != null;

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> loadProfileImage() async {
    final path = await _imageStorage.getSavedImagePath();
    profileImagePath.value = path ?? '';
  }

  Future<void> pickProfileImage() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return; // User cancelled.
      final savedPath = await _imageStorage.saveImage(picked.path);
      profileImagePath.value = savedPath;
    } catch (e) {
      errorMessage.value = 'Failed to select profile image.';
    }
  }

  Future<void> removeProfileImage() async {
    await _imageStorage.clearImage();
    profileImagePath.value = '';
  }

  bool get _isCacheStale =>
      _cachedAt == null || DateTime.now().difference(_cachedAt!) > _cacheTtl;

  Future<void> fetchProfile({bool forceRefresh = false}) async {
    // Cache-first: serve cached profile immediately when available.
    if (!forceRefresh && profile.value != null) {
      if (_isCacheStale) {
        _refreshProfileInBackground();
      }
      return;
    }

    // Deduplicate concurrent requests.
    if (_fetchInFlight != null) {
      return _fetchInFlight;
    }

    final future = _fetchProfile(background: false);
    _fetchInFlight = future;
    try {
      await future;
    } finally {
      if (_fetchInFlight == future) {
        _fetchInFlight = null;
      }
    }
  }

  Future<void> _refreshProfileInBackground() async {
    if (_fetchInFlight != null) return;
    final future = _fetchProfile(background: true);
    _fetchInFlight = future;
    try {
      await future;
    } finally {
      if (_fetchInFlight == future) {
        _fetchInFlight = null;
      }
    }
  }

  Future<void> _fetchProfile({bool background = false}) async {
    if (!background) {
      isLoading.value = true;
    }
    errorMessage.value = '';
    try {
      final result = await _getProfileOrRepository();
      profile.value = result;
      nameController.text = result.name;
      _cachedAt = DateTime.now();
    } on ApiErrorResponse catch (e) {
      errorMessage.value = e.displayMessage;
      _handleUnauthorized(e);
    } on ProfileException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!background) {
        isLoading.value = false;
      }
    }
    if (!Get.testMode && !background) {
      await loadProfileImage();
    }
  }

  Future<void> refreshProfile() async {
    _cachedAt = null;
    try {
      Get.find<ProfileRepository>().clearCache();
    } catch (_) {}
    return fetchProfile(forceRefresh: true);
  }

  Future<ProfileEntity?> updateProfile({
    String? name,
    String? avatar,
    bool clearAvatar = false,
  }) async {
    if (isUpdating.value) return null;

    final resolvedName = (name ?? nameController.text).trim();

    // Validation.
    if (resolvedName.isEmpty) {
      errorMessage.value = 'Name is required.';
      return null;
    }
    if (resolvedName.length > 100) {
      errorMessage.value = 'Name must be at most 100 characters.';
      return null;
    }

    isUpdating.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      final result = await _updateProfileOrRepository(
        name: resolvedName,
        avatar: avatar,
        clearAvatar: clearAvatar,
      );
      profile.value = result;
      nameController.text = result.name;
      _cachedAt = DateTime.now();
      successMessage.value = 'Profile updated successfully.';
      _safeSnackbar('Success', successMessage.value);
      return result;
    } on ApiErrorResponse catch (e) {
      errorMessage.value = e.displayMessage;
      _handleUnauthorized(e);
      _safeSnackbar('Error', errorMessage.value);
    } on ProfileException catch (e) {
      errorMessage.value = e.message;
      _safeSnackbar('Error', errorMessage.value);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      _safeSnackbar('Error', errorMessage.value);
    } finally {
      isUpdating.value = false;
    }
    return null;
  }

  void toggleTheme() {
    Get.find<ThemeController>().toggleTheme();
  }

  void logout() {
    Get.find<AuthController>().logout();
  }

  void clearCache() {
    profile.value = null;
    _cachedAt = null;
    _fetchInFlight = null;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      Get.find<ProfileRepository>().clearCache();
    } catch (_) {}
  }

  void goToEditProfile() {
    Get.toNamed(RouteNames.editProfile);
  }

  Future<ProfileEntity> _getProfileOrRepository() async {
    if (_getProfileUseCase != null) {
      return _getProfileUseCase.call();
    }
    if (_repository != null) {
      return _repository.getProfile();
    }
    throw const ProfileException('Profile repository is not configured.');
  }

  Future<ProfileEntity> _updateProfileOrRepository({
    required String name,
    String? avatar,
    bool clearAvatar = false,
  }) async {
    if (_updateProfileUseCase != null) {
      return _updateProfileUseCase.call(
        name: name,
        avatar: avatar,
        clearAvatar: clearAvatar,
      );
    }
    if (_repository != null) {
      return _repository.updateProfile(
        name: name,
        avatar: avatar,
        clearAvatar: clearAvatar,
      );
    }
    throw const ProfileException('Profile repository is not configured.');
  }

  void _handleUnauthorized(ApiErrorResponse e) {
    if (e.statusCode == 401) {
      // Preserve existing auth/session handling.
    }
  }

  void _safeSnackbar(String title, String message) {
    if (Get.testMode || Get.context == null) return;
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

class ProfileException implements Exception {
  final String message;
  const ProfileException(this.message);
  @override
  String toString() => message;
}
