import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class EmployeesController extends GetxController {
  final searchQuery = ''.obs;
  final employees = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadEmployees();
  }

  void _loadEmployees() {
    // Mock data - replace with API
    employees.value = [
      {
        'id': '1',
        'name': 'Karyawan1',
        'npk': 'NPK001',
        'position': 'Staff',
        'department': 'IT',
      },
      {
        'id': '2',
        'name': 'Karyawan2',
        'npk': 'NPK002',
        'position': 'Manager',
        'department': 'HR',
      },
      {
        'id': '3',
        'name': 'Karyawan3',
        'npk': 'NPK003',
        'position': 'Staff',
        'department': 'Finance',
      },
      {
        'id': '4',
        'name': 'Karyawan4',
        'npk': 'NPK004',
        'position': 'Staff',
        'department': 'Marketing',
      },
    ];
  }

  List<Map<String, dynamic>> get filteredEmployees {
    if (searchQuery.value.isEmpty) {
      return employees;
    }
    return employees.where((emp) {
      final name = emp['name']?.toString().toLowerCase() ?? '';
      final npk = emp['npk']?.toString().toLowerCase() ?? '';
      final query = searchQuery.value.toLowerCase();
      return name.contains(query) || npk.contains(query);
    }).toList();
  }

  void onSearch(String query) {
    searchQuery.value = query;
  }

  void goToEmployeeDetail(Map<String, dynamic> employee) {
    Get.toNamed(AppRoutes.adminEmployeeDetail, arguments: employee);
  }

  void goToAddEmployee() {
    Get.toNamed(AppRoutes.adminEmployeeAdd);
  }

  void deleteEmployee(String id) {
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
              employees.removeWhere((emp) => emp['id'] == id);
              Get.back();
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
