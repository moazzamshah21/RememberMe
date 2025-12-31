import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rememberme/app/constants/app_colors.dart';
import 'package:rememberme/app/controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_Login.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Title Section
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: AppColors.cyan,
                        fontFamily: 'PolySans'
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      '& Start Remembering.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: AppColors.cyan,
                        fontFamily: 'PolySans'
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                
                // Name Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PolySans',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteWithOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.whiteWithOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: controller.nameController,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontFamily: 'PolySans',
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Example: John Doe',
                          hintStyle: TextStyle(
                            color: AppColors.lightBlue,
                            fontFamily: 'PolySans',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PolySans',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteWithOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.whiteWithOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: TextFormField(
                        controller: controller.emailController,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontFamily: 'PolySans',
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Example: johndoe@gmail.com',
                          hintStyle: TextStyle(
                            color: AppColors.lightBlue,
                            fontFamily: 'PolySans',
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PolySans',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteWithOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.whiteWithOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontFamily: 'PolySans',
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                        decoration: InputDecoration(
                          hintText: '*********',
                          hintStyle: const TextStyle(
                            color: AppColors.lightBlue,
                            fontFamily: 'PolySans',
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.lightBlue,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                
                // Confirm Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'PolySans',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteWithOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.whiteWithOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Obx(() => TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.obscureConfirmPassword.value,
                        style: const TextStyle(
                          color: AppColors.cyan,
                          fontFamily: 'PolySans',
                          fontSize: 16,
                          letterSpacing: 2,
                        ),
                        decoration: InputDecoration(
                          hintText: '*********',
                          hintStyle: const TextStyle(
                            color: AppColors.lightBlue,
                            fontFamily: 'PolySans',
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureConfirmPassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.lightBlue,
                            ),
                            onPressed: controller.toggleConfirmPasswordVisibility,
                          ),
                        ),
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Register Button
                Obx(() => SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Material(
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: controller.isLoading.value ? null : controller.register,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: controller.isLoading.value
                              ? null
                              : const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    AppColors.lightBlue,
                                    AppColors.cyan,
                                  ],
                                ),
                          color: controller.isLoading.value
                              ? AppColors.lightBlue.withValues(alpha: 0.6)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowBlackHeavy,
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Centered Text or Loading Indicator
                            controller.isLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primaryBlue,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    "Register",
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'PolySans',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                            
                            // Icon at the end (only show when not loading)
                            if (!controller.isLoading.value)
                              const Positioned(
                                right: 20,
                                child: Icon(
                                  Icons.arrow_forward_rounded,
                                  color: AppColors.primaryBlue,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 15),
                
                // Divider with "or"
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.lightBlue,
                              AppColors.cyan,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: AppColors.whiteWithOpacity(0.8),
                          fontFamily: 'PolySans',
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.lightBlue,
                              AppColors.cyan,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
                // Google Register Button
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowBlackMedium,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: AppColors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: controller.googleRegister,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/Google.png'),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Register with Google',
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PolySans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Login Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              color: AppColors.cyan,
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w500
                            ),
                          ),
                          TextSpan(
                            text: 'Login here',
                            style: TextStyle(
                              color: AppColors.cyan,
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
