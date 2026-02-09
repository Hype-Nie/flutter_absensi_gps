import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'dashboard_employee_item.dart';

class AdminEmployeesPage extends StatelessWidget {
  const AdminEmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildSearchBar(controller),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildEmployeeList(controller),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AdminDashboardController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.onEmployeeSearch,
        decoration: InputDecoration(
          hintText: 'Cari berdasarkan nama atau NPK...',
          hintStyle: const TextStyle(color: AppColors.grey400, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeList(AdminDashboardController controller) {
    return Obx(() {
      final employees = controller.filteredEmployees;

      if (employees.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(Icons.people_outline, size: 64, color: AppColors.grey400),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada karyawan ditemukan',
                  style: const TextStyle(color: AppColors.grey600),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        children: employees
            .map((emp) => DashboardEmployeeItem(employee: emp))
            .toList(),
      );
    });
  }
}
