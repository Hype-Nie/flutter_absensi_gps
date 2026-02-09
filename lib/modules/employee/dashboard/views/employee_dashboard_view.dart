import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/employee_dashboard_controller.dart';
import '../widgets/employee_stat_card.dart';
import '../widgets/employee_attendance_item.dart';
import '../widgets/attendance_options_sheet.dart';

class EmployeeDashboardView extends GetView<EmployeeDashboardController> {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    _buildStatCards(),
                    const SizedBox(height: 24),
                    _buildAttendanceSection(),
                    const SizedBox(height: 16),
                    _buildAttendanceList(),
                    const SizedBox(height: 16),
                    _buildHistoryButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAttendanceOptionsSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.fingerprint, color: AppColors.textWhite),
        label: const Text(
          'Absensi',
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.grey300,
              border: Border.all(color: AppColors.grey400, width: 2),
            ),
            child: Icon(Icons.person, size: 35, color: AppColors.grey600),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              Obx(() => Text(
                controller.userName.value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              )),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: controller.logout,
            icon: const Icon(Icons.logout, color: AppColors.error),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => EmployeeStatCard(
              count: controller.attendanceCount.value.toString(),
              label: 'Hadir',
              color: AppColors.success,
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => EmployeeStatCard(
              count: controller.izinCount.value.toString(),
              label: 'Izin',
              color: AppColors.warning,
            )),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => EmployeeStatCard(
              count: controller.sakitCount.value.toString(),
              label: 'Sakit',
              color: AppColors.error,
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Absensi Terbaru',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey300),
            ),
            child: TextField(
              onChanged: controller.onSearch,
              decoration: InputDecoration(
                hintText: 'Cari',
                hintStyle: const TextStyle(color: AppColors.grey400),
                prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.recentAttendances.length,
          itemBuilder: (context, index) {
            final attendance = controller.recentAttendances[index];
            return EmployeeAttendanceItem(attendance: attendance);
          },
        ));
  }

  Widget _buildHistoryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.goToHistory,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.grey800,
            foregroundColor: AppColors.textWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Riwayat Lengkap',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.grey300,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Text(
        '@2026 Perhutani Padangan',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
      ),
    );
  }
}
