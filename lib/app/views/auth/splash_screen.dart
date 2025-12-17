import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/splash_controller.dart';
import 'get_started_screen.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Bg_splash.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated logo
              Obx(() => TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: controller.logoScale.value),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: const Image(image: AssetImage('assets/images/logo.png')),
              )),
              
              const SizedBox(height: 20),
              
              // Animated text
              Obx(() => TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: controller.textOpacity.value),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeIn,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Column(
                  children: const [
                    Text(
                      'RememberMe', 
                      style: TextStyle(
                        fontSize: 49, 
                        fontWeight: FontWeight.w700, 
                        color: AppColors.white, 
                        fontFamily: 'Futuru',
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The Smart Way to Remember People.', 
                      style: TextStyle(
                        fontFamily: 'Inter', 
                        fontWeight: FontWeight.w500, 
                        fontSize: 16, 
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}