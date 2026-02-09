import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../../data/models/employee_model.dart';

mixin EmployeesDataMixin on GetxController {
  // Employees Page Data
  final RxString employeeSearchQuery = ''.obs;
  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxBool isLoadingEmployees = false.obs;

  void loadEmployees();
  void onEmployeeSearch(String query) {
    employeeSearchQuery.value = query;
  }

  List<EmployeeModel> get filteredEmployees {
    if (employeeSearchQuery.value.isEmpty) {
      return employees;
    }
    return employees.where((emp) {
      final name = emp.name.toLowerCase();
      final npk = emp.npk.toLowerCase();
      final query = employeeSearchQuery.value.toLowerCase();
      return name.contains(query) || npk.contains(query);
    }).toList();
  }

  void goToEmployeeDetail(EmployeeModel employee) {
    Get.toNamed(AppRoutes.adminEmployeeDetail, arguments: employee.toJson());
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
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              employees.removeWhere((emp) => emp.id == id);
              Get.back();
              Get.snackbar(
                'Berhasil',
                'Karyawan berhasil dihapus',
                backgroundColor: AppColors.success,
                colorText: AppColors.textWhite,
                snackPosition: SnackPosition.TOP,
              );
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
