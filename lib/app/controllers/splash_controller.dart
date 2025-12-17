import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxDouble logoScale = 0.0.obs;
  final RxDouble textOpacity = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    startAnimations();
  }

  void startAnimations() {
    // First, zoom the logo
    Future.delayed(const Duration(milliseconds: 600), () {
      logoScale.value = 1.0;
    });

    // Then, fade in the text after delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      textOpacity.value = 1.0;
    });

    // Navigate to GetStartedScreen after total animation time
    Future.delayed(const Duration(milliseconds: 3500), () {
      Get.offNamed('/getStarted');
    });
  }
}
