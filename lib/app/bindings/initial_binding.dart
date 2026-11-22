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
import '../../features/tasks/data/datasources/task_api_data_source.dart';
import '../../features/tasks/data/repositories/task_repository_impl.dart';
import '../../features/tasks/domain/repositories/task_repository.dart';
import '../../features/tasks/domain/usecases/task_usecases.dart';
import '../../features/tasks/presentation/controllers/task_controller.dart';
import '../../features/notifications/data/datasources/notification_api_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/notification_usecases.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';
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
        tokenStorage: tokenStorage,
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

    // ── Task Data Layer ──────────────────────────────────────────
    final taskDataSource = TaskApiDataSource(dioClient.dio);
    Get.put<TaskApiDataSource>(taskDataSource, permanent: true);

    final taskRepository = TaskRepositoryImpl(dataSource: taskDataSource);
    Get.put<TaskRepository>(taskRepository, permanent: true);

    Get.put<CreateTaskUseCase>(
      CreateTaskUseCase(taskRepository),
      permanent: true,
    );
    Get.put<ListTasksUseCase>(
      ListTasksUseCase(taskRepository),
      permanent: true,
    );
    Get.put<GetTaskByIdUseCase>(
      GetTaskByIdUseCase(taskRepository),
      permanent: true,
    );
    Get.put<UpdateTaskUseCase>(
      UpdateTaskUseCase(taskRepository),
      permanent: true,
    );
    Get.put<DeleteTaskUseCase>(
      DeleteTaskUseCase(taskRepository),
      permanent: true,
    );
    Get.put<RefreshTasksUseCase>(
      RefreshTasksUseCase(taskRepository),
      permanent: true,
    );

    // ── Task Controllers ──────────────────────────────────────────
    Get.lazyPut<TaskController>(
      () => TaskController(
        createTaskUseCase: Get.find<CreateTaskUseCase>(),
        listTasksUseCase: Get.find<ListTasksUseCase>(),
        getTaskByIdUseCase: Get.find<GetTaskByIdUseCase>(),
        updateTaskUseCase: Get.find<UpdateTaskUseCase>(),
        deleteTaskUseCase: Get.find<DeleteTaskUseCase>(),
        refreshTasksUseCase: Get.find<RefreshTasksUseCase>(),
      ),
      fenix: true,
    );

    // ── Notification Data Layer ───────────────────────────────────
    final notificationDataSource = NotificationApiDataSource(dioClient.dio);
    Get.put<NotificationApiDataSource>(notificationDataSource, permanent: true);

    final notificationRepository = NotificationRepositoryImpl(
      dataSource: notificationDataSource,
    );
    Get.put<NotificationRepository>(notificationRepository, permanent: true);

    Get.put<RegisterDeviceTokenUseCase>(
      RegisterDeviceTokenUseCase(notificationRepository),
      permanent: true,
    );
    Get.put<RemoveDeviceTokenUseCase>(
      RemoveDeviceTokenUseCase(notificationRepository),
      permanent: true,
    );
    Get.put<ParseNotificationUseCase>(
      ParseNotificationUseCase(notificationRepository),
      permanent: true,
    );

    // ── Notification Controller ───────────────────────────────────
    Get.put<NotificationController>(
      NotificationController(
        registerDeviceTokenUseCase: Get.find<RegisterDeviceTokenUseCase>(),
        removeDeviceTokenUseCase: Get.find<RemoveDeviceTokenUseCase>(),
        parseNotificationUseCase: Get.find<ParseNotificationUseCase>(),
      ),
      permanent: true,
    );

    // ── Other Controllers ─────────────────────────────────────────
    Get.put<OnboardingController>(OnboardingController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<CalendarController>(() => CalendarController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<AIController>(() => AIController(), fenix: true);
    Get.lazyPut<StatisticsController>(
      () => StatisticsController(),
      fenix: true,
    );
  }
}
