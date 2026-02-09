import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../routes/app_routes.dart';

class PhotoValidationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  final isLoading = false.obs;
  final capturedImage = Rxn<File>();
  final isPhotoValid = true.obs;
  final errorMessage = ''.obs;

  final attendanceType = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;

  // Clock-in/out state
  final isClockOut = false.obs;
  final todayAttendance = Rxn<AttendanceHistoryModel>();
  final canSubmit = true.obs;
  final timeUntilCanSubmit = ''.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    latitude.value = args?['latitude'] ?? 0.0;
    longitude.value = args?['longitude'] ?? 0.0;

    _checkTodayAttendance();
  }

  Future<void> _checkTodayAttendance() async {
    final currentUser = _authService.currentUser.value;
    if (currentUser == null) return;

    isLoading.value = true;

    final attendance = await _attendanceService.getTodayAttendance(
      currentUser.id,
    );

    isLoading.value = false;

    if (attendance != null) {
      todayAttendance.value = attendance;

      // If already checked in but not checked out
      if (attendance.clockOut == null) {
        isClockOut.value = true;
        _checkIfCanClockOut();
      }
    }
  }

  void _checkIfCanClockOut() {
    final attendance = todayAttendance.value;
    if (attendance == null) return;

    // Check if current time is 9 AM or later
    final now = DateTime.now();
    final nineAM = DateTime(now.year, now.month, now.day, 9, 0, 0);

    if (now.isAfter(nineAM) || now.isAtSameMomentAs(nineAM)) {
      canSubmit.value = true;
      timeUntilCanSubmit.value = '';
    } else {
      canSubmit.value = false;
      final minutesUntilNine = nineAM.difference(now).inMinutes;
      timeUntilCanSubmit.value =
          'Tunggu $minutesUntilNine menit lagi untuk clock out';

      // Auto-check again after a minute
      Future.delayed(const Duration(minutes: 1), _checkIfCanClockOut);
    }
  }

  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 60, // Lower quality to reduce file size
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        final imageFile = File(image.path);
        final fileSize = await imageFile.length();
        final fileSizeInMB = fileSize / (1024 * 1024);

        // Check if file is too large (> 2MB)
        if (fileSizeInMB > 2.0) {
          Get.snackbar(
            'Peringatan',
            'Ukuran foto terlalu besar (${fileSizeInMB.toStringAsFixed(2)} MB). Silakan ambil ulang dengan pencahayaan lebih rendah.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.warning,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
          return;
        }

        capturedImage.value = imageFile;
        isPhotoValid.value = true;
        errorMessage.value = '';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengambil foto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> submitAttendance() async {
    if (capturedImage.value == null) {
      Get.snackbar(
        'Error',
        'Silakan ambil foto terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    // Check if can submit (for clock-out, must wait 1 hour)
    if (!canSubmit.value) {
      Get.snackbar(
        'Perhatian',
        timeUntilCanSubmit.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    final currentUser = _authService.currentUser.value;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'User tidak ditemukan. Silakan login kembali',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      late final result;

      if (isClockOut.value && todayAttendance.value != null) {
        // Clock Out
        result = await _attendanceService.clockOut(
          attendanceId: todayAttendance.value!.id,
          clockOutImage: capturedImage.value!,
          clockOutLat: latitude.value,
          clockOutLong: longitude.value,
        );
      } else {
        // Clock In
        result = await _attendanceService.clockIn(
          userId: currentUser.id,
          tanggal: DateTime.now(),
          clockInImage: capturedImage.value!,
          clockInLat: latitude.value,
          clockInLong: longitude.value,
        );
      }

      isLoading.value = false;

      if (result.isSuccess && result.data != null) {
        Get.snackbar(
          'Berhasil',
          isClockOut.value ? 'Clock out berhasil' : 'Clock in berhasil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate to success page with attendance data
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offNamed(
            AppRoutes.employeeAttendanceSuccess,
            arguments: {
              'type': attendanceType.value,
              'isCheckIn': !isClockOut.value,
              'attendanceData': result.data,
            },
          );
        });
      } else {
        // Show detailed error message
        final errorMsg = result.error ?? 'Gagal menyimpan absensi';

        Get.dialog(
          AlertDialog(
            title: const Text('Error'),
            content: SingleChildScrollView(child: Text(errorMsg)),
            actions: [
              TextButton(onPressed: () => Get.back(), child: const Text('OK')),
            ],
          ),
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void retakePhoto() {
    capturedImage.value = null;
    isPhotoValid.value = true;
    errorMessage.value = '';
  }
}
