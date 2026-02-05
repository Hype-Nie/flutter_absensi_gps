import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // "Login" Title
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900, // Extra Bold
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // Logo Placeholder
                    Center(
                      child: Container(
                        width: 150,
                        height: 150,
                        color: Colors.grey[300], // Placeholder color
                        alignment: Alignment.center,
                        child: const Text(
                          'Logo Apps',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // "Perhutani Padangan"
                    const Text(
                      'Perhutani Padangan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 60),

                    // NPK Input
                    const Text(
                      'NPK',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.npkController,
                      decoration: InputDecoration(
                        hintText: 'NPK',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Input
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => TextField(
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        // Assuming no icon in wireframe, but keeping visibility toggle for UX might be good.
                        // Wireframe just shows plain text field. I'll omit the icon to be strict to wireframe 
                        // or add it subtly. I'll add it because it's standard UX, but keep it minimal.
                        // User asked for "Modern UI", so a toggle is expected.
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordVisible.value
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                      ),
                    )),
                    const SizedBox(height: 40),

                    // Login Button
                    Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary, // Green
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    )),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[300], // Light gray background for footer
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                '@2026 Perhutani Padangan',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}