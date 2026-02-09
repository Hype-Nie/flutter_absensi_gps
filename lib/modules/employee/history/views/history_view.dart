import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Get.back(),
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Riwayat Absensi\nKaryawan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => _buildStatCard(
                            count: controller.attendanceCount.value.toString(),
                            label: 'Hadir',
                            color: AppColors.success,
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => _buildStatCard(
                            count: controller.izinCount.value.toString(),
                            label: 'Izin',
                            color: AppColors.warning,
                          )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => _buildStatCard(
                            count: controller.sakitCount.value.toString(),
                            label: 'Sakit',
                            color: AppColors.error,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Filter Chips
                    Obx(() => Wrap(
                      spacing: 8,
                      children: controller.filters.map((filter) {
                        final isSelected = controller.selectedFilter.value == filter;
                        return FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) => controller.setFilter(filter),
                          selectedColor: AppColors.primary.withValues(alpha:0.2),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primary : AppColors.grey600,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.grey300,
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                    const SizedBox(height: 16),

                    // Search Bar
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
                    const SizedBox(height: 16),

                    // Attendance List
                    Obx(() => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.filteredAttendances.length,
                      itemBuilder: (context, index) {
                        final attendance = controller.filteredAttendances[index];
                        return _buildAttendanceItem(attendance);
                      },
                    )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.grey300,
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                '@2026 Perhutani Padangan',
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(Map<String, dynamic> attendance) {
    Color statusColor;
    switch (attendance['status']) {
      case 'Hadir':
        statusColor = AppColors.success;
        break;
      case 'Sakit':
        statusColor = AppColors.error;
        break;
      case 'Izin':
        statusColor = AppColors.warning;
        break;
      default:
        statusColor = AppColors.grey600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.grey300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.person, color: AppColors.grey500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance['date'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jam Masuk:  ${attendance['jamMasuk']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  'Jam Keluar:  ${attendance['jamKeluar']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha:0.5)),
            ),
            child: Text(
              attendance['status'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
