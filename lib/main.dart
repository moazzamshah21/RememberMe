import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/controllers/bottom_tabs_controller.dart';
import 'package:rememberme/app/controllers/favorites_controller.dart';
import 'package:rememberme/app/controllers/login_controller.dart';
import 'package:rememberme/app/controllers/register_controller.dart';
import 'package:rememberme/app/controllers/search_controller.dart' as app;
import 'package:rememberme/app/controllers/settings_controller.dart';
import 'package:rememberme/app/controllers/splash_controller.dart';
import 'package:rememberme/app/views/auth/splash_screen.dart';
import 'package:rememberme/app/views/auth/get_started_screen.dart';
import 'package:rememberme/app/views/auth/login_screen.dart';
import 'package:rememberme/app/views/auth/register_screen.dart';
import 'package:rememberme/app/navigation/BottomTabs.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RememberMe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        // Initialize all controllers
        Get.put(SplashController(), permanent: true);
        Get.put(BottomTabsController(), permanent: true);
        Get.put(SettingsController(), permanent: true);
        Get.put(FavoritesController(), permanent: true);
        Get.put(app.AppSearchController(), permanent: true);
        // LoginController will be created when needed (not permanent)
      }),
      home: const SplashScreen(),
      getPages: [
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
        ),
        GetPage(
          name: '/getStarted',
          page: () => const GetStartedScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => LoginController());
          }),
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          transition: Transition.rightToLeft,
          transitionDuration: const Duration(milliseconds: 300),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => RegisterController());
          }),
        ),
        GetPage(
          name: '/home',
          page: () => const BottomTabs(),
        ),
      ],
    );
  }
}