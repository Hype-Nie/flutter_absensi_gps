import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmployeeFormController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final npkController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final isEditMode = false.obs;
  final isLoading = false.obs;
  final showPassword = false.obs;
  final showConfirmPassword = false.obs;
  
  Map<String, dynamic>? employeeData;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      isEditMode.value = true;
      employeeData = args;
      _populateForm();
    }
  }

  void _populateForm() {
    if (employeeData != null) {
      nameController.text = employeeData!['name'] ?? '';
      npkController.text = employeeData!['npk'] ?? '';
    }
  }

  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    showConfirmPassword.value = !showConfirmPassword.value;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateNPK(String? value) {
    if (value == null || value.isEmpty) {
      return 'NPK tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'NPK minimal 3 karakter';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (!isEditMode.value) {
      if (value == null || value.isEmpty) {
        return 'Password tidak boleh kosong';
      }
      if (value.length < 6) {
        return 'Password minimal 6 karakter';
      }
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (!isEditMode.value || passwordController.text.isNotEmpty) {
      if (value != passwordController.text) {
        return 'Konfirmasi password tidak cocok';
      }
    }
    return null;
  }

  void saveEmployee() {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 1), () {
        isLoading.value = false;
        Get.back();
        Get.snackbar(
          'Berhasil',
          isEditMode.value 
              ? 'Data karyawan berhasil diperbarui'
              : 'Karyawan baru berhasil ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      });
    }
  }

  void goBack() {
    Get.back();
  }

  @override
  void onClose() {
    nameController.dispose();
    npkController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
