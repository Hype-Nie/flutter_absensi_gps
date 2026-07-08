import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/security_service.dart';

class LocationPoint {
  final String name;
  final LatLng position;

  const LocationPoint({required this.name, required this.position});
}

class GpsValidationController extends GetxController {
  final SecurityService _securityService = Get.find<SecurityService>();

  final isLoading = false.obs;
  final isLocationValid = false.obs;
  final currentPosition = Rxn<Position>();
  final attendanceType = ''.obs;
  final nearestPoint = Rxn<LocationPoint>();
  final distanceToNearest = 0.0.obs;

  // Security status
  final isSecurityChecking = false.obs;
  final securityWarnings = <String>[].obs;

  // Clock-in/out state
  final isClockOut = false.obs;

  // Outside location state
  final isOutsideLocation = false.obs;

  // Validation radius in meters
  final double validationRadius = 400.0;

  // 10 predefined location points - User akan sesuaikan koordinatnya nanti
  final List<LocationPoint> validationPoints = const [
    // LocationPoint(name: 'Lokasi 1', position: LatLng(-8.151595, 113.734986)),
    // -8.146741853572067, 113.68633453931135s
    LocationPoint(name: 'Lokasi 1', position: LatLng(-7.15162, 111.60486)),
    LocationPoint(name: 'Lokasi 2', position: LatLng(-8.146741, 113.686334)),
    LocationPoint(name: 'Lokasi 3', position: LatLng(-8.151595, 113.734986)),
    LocationPoint(name: 'Lokasi 4', position: LatLng(-8.17268, 113.68994)),
    LocationPoint(name: 'Lokasi 5', position: LatLng(-7.2595, 112.7540)),
    LocationPoint(name: 'Lokasi 6', position: LatLng(-7.2600, 112.7545)),
    LocationPoint(name: 'Lokasi 7', position: LatLng(-7.2605, 112.7550)),
    LocationPoint(name: 'Lokasi 8', position: LatLng(-7.2610, 112.7555)),
    LocationPoint(name: 'Lokasi 9', position: LatLng(-7.2615, 112.7560)),
    LocationPoint(name: 'Lokasi 10', position: LatLng(-7.2620, 112.7565)),
    LocationPoint(name: 'Lokasi 11', position: LatLng(-7.2977, 112.7667)),
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    isClockOut.value = args?['isClockOut'] ?? false;
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

  Future<void> validateLocation() async {
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

    // Show loading for security check
    isSecurityChecking.value = true;

    // Perform comprehensive security check
    final securityReport = await _securityService.performSecurityCheck(
      currentPosition.value!,
    );

    isSecurityChecking.value = false;
    securityWarnings.value = securityReport.warnings;

    // Check if security check passed
    if (!securityReport.isSecure) {
      _showSecurityWarningDialog(securityReport);
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
      isOutsideLocation.value = false;
      isLocationValid.value = true;
      Get.snackbar(
        'Validasi Berhasil',
        'Anda berada di ${closestPoint?.name} (${minDistance.toStringAsFixed(0)}m)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      Future.delayed(const Duration(seconds: 2), () {
        Get.toNamed(
          AppRoutes.employeeFaceVerification,
          arguments: {
            'type': attendanceType.value,
            'latitude': currentPosition.value!.latitude,
            'longitude': currentPosition.value!.longitude,
            'accurateTime': securityReport.accurateTime,
            'isClockOut': isClockOut.value,
            'isOutsideLocation': false,
          },
        );
      });
    } else {
      isLocationValid.value = false;
      _showOutsideLocationDialog(closestPoint, minDistance, securityReport);
    }
  }

  void _showOutsideLocationDialog(
    LocationPoint? closestPoint,
    double distance,
    SecurityReport securityReport,
  ) {
    Get.dialog(
      AlertDialog(
        icon: Icon(Icons.location_off, color: Colors.orange, size: 48),
        title: const Text('Diluar Area Lokasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anda berada di luar area lokasi yang ditentukan.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Jarak: ${distance.toStringAsFixed(0)}m dari ${closestPoint?.name ?? "lokasi terdekat"}',
              style: const TextStyle(fontSize: 13),
            ),
            Text(
              'Jarak maksimal: ${validationRadius.toStringAsFixed(0)}m',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'Jika melanjutkan, absensi Anda akan berstatus "Menunggu Konfirmasi" dan memerlukan persetujuan admin.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(closeOverlays: true),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(closeOverlays: true);
              isOutsideLocation.value = true;
              Get.toNamed(
                AppRoutes.employeeFaceVerification,
                arguments: {
                  'type': attendanceType.value,
                  'latitude': currentPosition.value!.latitude,
                  'longitude': currentPosition.value!.longitude,
                  'accurateTime': securityReport.accurateTime,
                  'isClockOut': isClockOut.value,
                  'isOutsideLocation': true,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showSecurityWarningDialog(SecurityReport report) {
    Get.dialog(
      AlertDialog(
        icon: Icon(Icons.block, color: Colors.red, size: 48),
        title: const Text('Absensi Ditolak', style: TextStyle(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terdeteksi aktivitas mencurigakan. Anda tidak dapat melakukan absensi.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...report.warnings.map(
              (warning) => Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: Text(warning, style: TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan periksa perangkat Anda dan hubungi admin jika ini adalah kesalahan.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(closeOverlays: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kembali'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void refreshLocation() {
    _getCurrentLocation();
  }
}
