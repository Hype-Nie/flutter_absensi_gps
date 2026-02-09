import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_colors.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelector(controller),
                const SizedBox(height: 16),
                _buildSummaryCards(controller),
                const SizedBox(height: 24),
                _buildReportTable(controller),
              ],
            ),
          ),
        ),
        _buildExportButton(controller),
      ],
    );
  }

  Widget _buildMonthSelector(AdminDashboardController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(Icons.calendar_month, color: AppColors.grey600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Periode',
                  style: TextStyle(fontSize: 12, color: AppColors.grey500),
                ),
                Obx(
                  () => Text(
                    controller.monthYearText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) => TextButton.icon(
              onPressed: () => controller.selectMonth(context),
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Ubah'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(AdminDashboardController controller) {
    return Obx(() {
      int totalHadir = 0;
      int totalIzin = 0;
      int totalSakit = 0;

      for (var report in controller.reports) {
        totalHadir += report.hadir;
        totalIzin += report.izin;
        totalSakit += report.sakit;
      }

      return Row(
        children: [
          Expanded(
            child: _buildReportSummaryCard(
              title: 'Total Hadir',
              value: totalHadir.toString(),
              icon: Icons.check_circle_outline,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildReportSummaryCard(
              title: 'Total Izin',
              value: totalIzin.toString(),
              icon: Icons.event_note_outlined,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildReportSummaryCard(
              title: 'Total Sakit',
              value: totalSakit.toString(),
              icon: Icons.medical_services_outlined,
              color: AppColors.error,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildReportSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.grey600),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTable(AdminDashboardController controller) {
    return Obx(
      () => Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Detail Absensi Karyawan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.grey100),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Nama',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'NPK',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Hadir',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Izin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Sakit',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: controller.reports.map((report) {
                  return DataRow(
                    cells: [
                      DataCell(Text(report.name)),
                      DataCell(Text(report.npk)),
                      DataCell(
                        Text(
                          report.hadir.toString(),
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          report.izin.toString(),
                          style: const TextStyle(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          report.sakit.toString(),
                          style: const TextStyle(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(AdminDashboardController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(
        () => ElevatedButton.icon(
          onPressed: controller.isLoadingReports.value
              ? null
              : controller.exportReport,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.textWhite,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: controller.isLoadingReports.value
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.textWhite,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.download),
          label: Text(
            controller.isLoadingReports.value
                ? 'Mengexport...'
                : 'Export Laporan',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
