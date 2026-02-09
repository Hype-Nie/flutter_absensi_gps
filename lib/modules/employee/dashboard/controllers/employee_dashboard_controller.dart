import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';

class EmployeeDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final greeting = ''.obs;
  final userName = ''.obs;
  final attendanceCount = 0.obs;
  final izinCount = 0.obs;
  final sakitCount = 0.obs;
  final searchQuery = ''.obs;
  
  final recentAttendances = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateGreeting();
    _loadAttendanceData();
  }

  void _loadUserData() {
    // Observe user changes
    ever(_authService.currentUser, (user) {
      if (user != null) {
        userName.value = user.nama;
      }
    });

    // Initial load
    if (_authService.currentUser.value != null) {
      userName.value = _authService.currentUser.value!.nama;
    }
  }

  void _updateGreeting() {
    greeting.value = Helpers.getGreeting();
  }

  void _loadAttendanceData() {
    // Mock data - replace with API call
    attendanceCount.value = 20;
    izinCount.value = 2;
    sakitCount.value = 1;

    recentAttendances.value = [
      {
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '-',
        'status': 'Hadir',
      },
      {
        'date': '20/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '17:00',
        'status': 'Sakit',
      },
      {
        'date': '19/01/2026',
        'jamMasuk': '08:15',
        'jamKeluar': '17:00',
        'status': 'Hadir',
      },
    ];
  }

  void onSearch(String query) {
    searchQuery.value = query;
  }

  void goToHistory() {
    Get.toNamed(AppRoutes.employeeHistory);
  }

  void goToAttendance(String type) {
    Get.toNamed(
      AppRoutes.employeeGpsValidation,
      arguments: {'type': type},
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
