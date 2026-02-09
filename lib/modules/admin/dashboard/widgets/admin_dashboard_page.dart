import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'dashboard_stat_card.dart';
import 'dashboard_attendance_item.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(controller),
          const SizedBox(height: 24),
          _buildSearchBar(controller),
          const SizedBox(height: 16),
          _buildAttendanceList(controller),
        ],
      ),
    );
  }

  Widget _buildStatCards(AdminDashboardController controller) {
    return Row(
      children: [
        Expanded(
          child: DashboardStatCard(
            icon: Icons.check_circle_outline,
            title: 'Total Hadir',
            value: controller.totalHadir,
            color: AppColors.success,
            bgColor: AppColors.success.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            icon: Icons.event_note_outlined,
            title: 'Total Ijin',
            value: controller.totalIzin,
            color: AppColors.orange,
            bgColor: AppColors.orange.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardStatCard(
            icon: Icons.medical_services_outlined,
            title: 'Total Sakit',
            value: controller.totalSakit,
            color: AppColors.error,
            bgColor: AppColors.error.withValues(alpha: 0.1),
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
        onChanged: controller.onSearch,
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

  Widget _buildAttendanceList(AdminDashboardController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Absensi Hari Ini',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.attendanceList.map(
            (attendance) => DashboardAttendanceItem(attendance: attendance),
          ),
        ],
      ),
    );
  }
}
