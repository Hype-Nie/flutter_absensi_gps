import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_routes.dart';

class AdminDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final greeting = ''.obs;
  final userName = ''.obs;
  final currentDate = ''.obs;
  
  final totalHadir = 0.obs;
  final totalIzin = 0.obs;
  final totalSakit = 0.obs;
  
  final searchQuery = ''.obs;
  final currentTabIndex = 0.obs;
  
  final attendanceList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateGreeting();
    _loadDashboardData();
  }

  void _loadUserData() {
    // Observe user changes
    ever(_authService.currentUser, (user) {
      if (user != null) {
        userName.value = user.name;
      }
    });

    // Initial load
    if (_authService.currentUser.value != null) {
      userName.value = _authService.currentUser.value!.name;
    }
  }

  void _updateGreeting() {
    greeting.value = Helpers.getGreeting();
    final now = DateTime.now();
    currentDate.value = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
  }

  void _loadDashboardData() {
    // Mock data - replace with API
    totalHadir.value = 45;
    totalIzin.value = 3;
    totalSakit.value = 2;

    attendanceList.value = [
      {
        'name': 'Karyawan1',
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '-',
        'status': 'Hadir',
      },
      {
        'name': 'Karyawan2',
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '-',
        'status': 'Sakit',
      },
      {
        'name': 'Karyawan3',
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '-',
        'status': 'Sakit',
      },
    ];
  }

  void onSearch(String query) {
    searchQuery.value = query;
  }

  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  void goToEmployees() {
    Get.toNamed(AppRoutes.adminEmployees);
  }

  void goToReports() {
    Get.toNamed(AppRoutes.adminReports);
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
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
