import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../routes/app_routes.dart';

class LocationPoint {
  final String name;
  final LatLng position;

  const LocationPoint({required this.name, required this.position});
}

class GpsValidationController extends GetxController {
  final isLoading = false.obs;
  final isLocationValid = false.obs;
  final currentPosition = Rxn<Position>();
  final attendanceType = ''.obs;
  final nearestPoint = Rxn<LocationPoint>();
  final distanceToNearest = 0.0.obs;

  // Validation radius in meters
  final double validationRadius = 200.0;

  // 10 predefined location points - User akan sesuaikan koordinatnya nanti
  final List<LocationPoint> validationPoints = const [
    LocationPoint(name: 'Lokasi 1', position: LatLng(-8.151595, 113.734986)),
    LocationPoint(name: 'Lokasi 2', position: LatLng(-8.146722, 113.686282)),
    LocationPoint(name: 'Lokasi 3', position: LatLng(-7.2585, 112.7530)),
    LocationPoint(name: 'Lokasi 4', position: LatLng(-7.2590, 112.7535)),
    LocationPoint(name: 'Lokasi 5', position: LatLng(-7.2595, 112.7540)),
    LocationPoint(name: 'Lokasi 6', position: LatLng(-7.2600, 112.7545)),
    LocationPoint(name: 'Lokasi 7', position: LatLng(-7.2605, 112.7550)),
    LocationPoint(name: 'Lokasi 8', position: LatLng(-7.2610, 112.7555)),
    LocationPoint(name: 'Lokasi 9', position: LatLng(-7.2615, 112.7560)),
    LocationPoint(name: 'Lokasi 10', position: LatLng(-7.2620, 112.7565)),
  ];

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

    // Find nearest point and calculate distance
    LocationPoint? closestPoint;
    double minDistance = double.infinity;

    for (var point in validationPoints) {
      double distance = Geolocator.distanceBetween(
        currentPosition.value!.latitude,
        currentPosition.value!.longitude,
        point.position.latitude,
        point.position.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = point;
      }
    }

    nearestPoint.value = closestPoint;
    distanceToNearest.value = minDistance;

    // Validate if within radius
    if (minDistance <= validationRadius) {
      isLocationValid.value = true;
      Get.snackbar(
        'Validasi Berhasil',
        'Anda berada di ${closestPoint?.name} (${minDistance.toStringAsFixed(0)}m)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Navigate to photo validation after short delay
      Future.delayed(const Duration(seconds: 2), () {
        Get.toNamed(
          AppRoutes.employeePhotoValidation,
          arguments: {
            'type': attendanceType.value,
            'latitude': currentPosition.value!.latitude,
            'longitude': currentPosition.value!.longitude,
          },
        );
      });
    } else {
      isLocationValid.value = false;
      Get.snackbar(
        'Validasi Gagal',
        'Anda berada ${minDistance.toStringAsFixed(0)}m dari ${closestPoint?.name}.\nJarak maksimal: ${validationRadius.toStringAsFixed(0)}m',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void refreshLocation() {
    _getCurrentLocation();
  }
}
