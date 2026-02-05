import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class EmployeeDetailController extends GetxController {
  final employee = Rxn<Map<String, dynamic>>();
  final selectedFilter = 'Semua'.obs;
  final filters = ['Semua', 'Hadir', 'Izin', 'Sakit'];
  final attendanceHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      employee.value = args;
      _loadAttendanceHistory();
    }
  }

  void _loadAttendanceHistory() {
    // Mock data - replace with API
    attendanceHistory.value = [
      {
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '17:00',
        'status': 'Hadir',
      },
      {
        'date': '20/01/2026',
        'jamMasuk': '08:15',
        'jamKeluar': '17:00',
        'status': 'Hadir',
      },
      {
        'date': '19/01/2026',
        'jamMasuk': '-',
        'jamKeluar': '-',
        'status': 'Sakit',
      },
      {
        'date': '18/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '17:00',
        'status': 'Hadir',
      },
    ];
  }

  List<Map<String, dynamic>> get filteredHistory {
    if (selectedFilter.value == 'Semua') {
      return attendanceHistory;
    }
    return attendanceHistory.where((att) => att['status'] == selectedFilter.value).toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void goToEditEmployee() {
    Get.toNamed(AppRoutes.adminEmployeeEdit, arguments: employee.value);
  }

  void deleteEmployee() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus karyawan ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(); // Go back to list
              Get.snackbar(
                'Berhasil',
                'Karyawan berhasil dihapus',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void goBack() {
    Get.back();
  }
}
