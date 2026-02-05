import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../routes/app_routes.dart';

class GpsValidationController extends GetxController {
  final isLoading = false.obs;
  final isLocationValid = false.obs;
  final currentPosition = Rxn<Position>();
  final attendanceType = ''.obs;
  
  // Office location (example coordinates - replace with actual)
  final double officeLatitude = -7.2575;
  final double officeLongitude = 112.7521;
  final double maxDistance = 100; // meters

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    isLoading.value = true;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Error',
          'Layanan lokasi tidak aktif',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        isLoading.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Error',
            'Izin lokasi ditolak',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition.value = position;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mendapatkan lokasi: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void validateLocation() {
    if (currentPosition.value == null) {
      Get.snackbar(
        'Error',
        'Lokasi belum tersedia',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    double distance = Geolocator.distanceBetween(
      currentPosition.value!.latitude,
      currentPosition.value!.longitude,
      officeLatitude,
      officeLongitude,
    );

    if (distance <= maxDistance) {
      isLocationValid.value = true;
      Get.toNamed(
        AppRoutes.employeePhotoValidation,
        arguments: {
          'type': attendanceType.value,
          'latitude': currentPosition.value!.latitude,
          'longitude': currentPosition.value!.longitude,
        },
      );
    } else {
      Get.snackbar(
        'Lokasi Tidak Valid',
        'Anda berada ${distance.toStringAsFixed(0)}m dari lokasi kantor',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  void refreshLocation() {
    _getCurrentLocation();
  }
}
