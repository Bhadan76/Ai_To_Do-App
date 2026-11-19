import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/route_names.dart';
import 'theme/light_theme.dart';
import 'theme/dark_theme.dart';
import 'bindings/initial_binding.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TodoApp',
      debugShowCheckedModeBanner: false,
      initialRoute: RouteNames.splash,
      initialBinding: InitialBinding(),
      getPages: AppPages.pages,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: ThemeMode.light,
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
