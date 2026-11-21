import 'package:get/get.dart';

import '../../core/api/dio_client.dart';
import '../../core/api/token_storage.dart';
import '../../features/authentication/data/datasources/auth_api_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/auth_usecases.dart';
import '../../features/authentication/presentation/controllers/auth_controller.dart';
import '../../features/categories/data/datasources/category_api_data_source.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/usecases/category_usecases.dart';
import '../../features/categories/presentation/controllers/category_controller.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/onboarding/presentation/controllers/onboarding_controller.dart';
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
    // ── Theme ──────────────────────────────────────────────────────
    Get.put<ThemeController>(ThemeController(), permanent: true);

    // ── Networking ─────────────────────────────────────────────────
    final tokenStorage = SecureTokenStorage();
    Get.put<TokenStorage>(tokenStorage, permanent: true);

    final dioClient = DioClient.instance;
    dioClient.initialize(tokenStorage: tokenStorage);

    // ── Auth Data Layer ───────────────────────────────────────────
    final authDataSource = AuthApiDataSource(dioClient.dio);
    Get.put<AuthApiDataSource>(authDataSource, permanent: true);

    final authRepository = AuthRepositoryImpl(
      dataSource: authDataSource,
      tokenStorage: tokenStorage,
    );
    Get.put<AuthRepository>(authRepository, permanent: true);

    // ── Auth Use Cases ────────────────────────────────────────────
    Get.put<LoginUseCase>(LoginUseCase(authRepository), permanent: true);
    Get.put<RegisterUseCase>(RegisterUseCase(authRepository), permanent: true);
    Get.put<LogoutUseCase>(LogoutUseCase(authRepository), permanent: true);
    Get.put<RestoreSessionUseCase>(
      RestoreSessionUseCase(authRepository),
      permanent: true,
    );

    // ── Auth Controllers ──────────────────────────────────────────
    Get.put<AuthController>(
      AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        restoreSessionUseCase: Get.find<RestoreSessionUseCase>(),
      ),
      permanent: true,
    );

    // ── Category Data Layer ───────────────────────────────────────
    final categoryDataSource = CategoryApiDataSource(dioClient.dio);
    Get.put<CategoryApiDataSource>(categoryDataSource, permanent: true);

    final categoryRepository = CategoryRepositoryImpl(
      dataSource: categoryDataSource,
    );
    Get.put<CategoryRepository>(categoryRepository, permanent: true);

    // ── Category Use Cases ────────────────────────────────────────
    Get.put<ListCategoriesUseCase>(
      ListCategoriesUseCase(categoryRepository),
      permanent: true,
    );
    Get.put<CreateCategoryUseCase>(
      CreateCategoryUseCase(categoryRepository),
      permanent: true,
    );
    Get.put<GetCategoryByIdUseCase>(
      GetCategoryByIdUseCase(categoryRepository),
      permanent: true,
    );
    Get.put<UpdateCategoryUseCase>(
      UpdateCategoryUseCase(categoryRepository),
      permanent: true,
    );
    Get.put<DeleteCategoryUseCase>(
      DeleteCategoryUseCase(categoryRepository),
      permanent: true,
    );
    Get.put<RefreshCategoriesUseCase>(
      RefreshCategoriesUseCase(categoryRepository),
      permanent: true,
    );

    // ── Category Controllers ──────────────────────────────────────
    Get.put<CategoryController>(
      CategoryController(
        listUseCase: Get.find<ListCategoriesUseCase>(),
        createUseCase: Get.find<CreateCategoryUseCase>(),
        updateUseCase: Get.find<UpdateCategoryUseCase>(),
        deleteUseCase: Get.find<DeleteCategoryUseCase>(),
      ),
      permanent: true,
    );

    // ── Other Controllers ─────────────────────────────────────────
    Get.put<OnboardingController>(OnboardingController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<TaskController>(() => TaskController(), fenix: true);
    Get.lazyPut<CalendarController>(() => CalendarController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<AIController>(() => AIController(), fenix: true);
    Get.lazyPut<StatisticsController>(() => StatisticsController(), fenix: true);
  }
}
