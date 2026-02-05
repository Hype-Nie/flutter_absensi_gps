import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/services/storage_service.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final StorageService _storageService = Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final selectedRole = 'employee'.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void selectRole(String role) {
    selectedRole.value = role;
    Get.snackbar(
      'Role Selected',
      'Login sebagai ${role == 'admin' ? 'Admin' : 'Karyawan'}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  Future<void> login() async {
    // Validate inputs
    if (!_validateInputs()) return;

    isLoading.value = true;

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock login success
      final userData = {
        'id': '1',
        'name': selectedRole.value == 'admin' ? 'Admin User' : 'Employee User',
        'email': emailController.text,
        'role': selectedRole.value,
      };

      // Save to storage
      await _storageService.saveUser(userData);
      await _storageService.saveToken('mock_token_123456');
      await _storageService.setLoggedIn(true);

      // Show success message
      Get.snackbar(
        'Success',
        AppStrings.successLogin,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate based on role
      if (selectedRole.value == 'admin') {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.employeeDashboard);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        AppStrings.errorGeneral,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email ${AppStrings.errorFieldRequired.toLowerCase()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!Helpers.isValidEmail(emailController.text)) {
      Get.snackbar(
        'Error',
        AppStrings.errorInvalidEmail,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Password ${AppStrings.errorFieldRequired.toLowerCase()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!Helpers.isValidPassword(passwordController.text)) {
      Get.snackbar(
        'Error',
        AppStrings.errorPasswordTooShort,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }
}
