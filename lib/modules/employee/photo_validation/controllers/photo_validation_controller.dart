import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../routes/app_routes.dart';

class PhotoValidationController extends GetxController {
  final isLoading = false.obs;
  final capturedImage = Rxn<File>();
  final isPhotoValid = true.obs;
  final errorMessage = ''.obs;
  
  final attendanceType = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    latitude.value = args?['latitude'] ?? 0.0;
    longitude.value = args?['longitude'] ?? 0.0;
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );

      if (image != null) {
        capturedImage.value = File(image.path);
        isPhotoValid.value = true;
        errorMessage.value = '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void validateLocation() {
    if (capturedImage.value == null) {
      Get.snackbar(
        'Error',
        'Silakan ambil foto terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Simulate photo validation
    // In real app, this would use face recognition API
    isLoading.value = true;
    
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      
      // Simulate validation result - always success for demo
      _submitAttendance();
    });
  }

  void _submitAttendance() {
    // Submit attendance to API
    isLoading.value = true;
    
    Future.delayed(const Duration(seconds: 1), () {
      isLoading.value = false;
      
      Get.offNamed(
        AppRoutes.employeeAttendanceSuccess,
        arguments: {
          'type': attendanceType.value,
          'isCheckIn': true, // or false for checkout
        },
      );
    });
  }

  void retakePhoto() {
    capturedImage.value = null;
    isPhotoValid.value = true;
    errorMessage.value = '';
  }
}
