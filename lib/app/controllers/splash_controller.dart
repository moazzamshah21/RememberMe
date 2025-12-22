import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
  final RxDouble logoScale = 0.0.obs;
  final RxDouble textOpacity = 0.0.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

    // Navigate after total animation time
    Future.delayed(const Duration(milliseconds: 3500), () {
      navigateToNextScreen();
    });
  }

  Future<void> navigateToNextScreen() async {
    // Check if user is already logged in
    final User? currentUser = _auth.currentUser;
    
    if (currentUser != null) {
      // User is logged in, go directly to home
      Get.offNamed('/home');
      return;
    }

    // Check if it's the first time opening the app
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (isFirstTime) {
      // First time opening the app, show GetStarted screen
      // Mark that we've shown it
      await prefs.setBool('is_first_time', false);
      Get.offNamed('/getStarted');
    } else {
      // Not first time, go directly to login
      Get.offNamed('/login');
    }
  }
}
