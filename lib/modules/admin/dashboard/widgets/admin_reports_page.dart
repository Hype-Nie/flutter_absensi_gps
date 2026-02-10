import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminDashboardController>();

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.loadReports,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    controller.reportMonthYearText,
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
      return Row(
        children: [
          Expanded(
            child: _buildReportSummaryCard(
              title: 'Total Hadir',
              value: controller.reportTotalHadir.toString(),
              icon: Icons.check_circle_outline,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildReportSummaryCard(
              title: 'Total Izin',
              value: controller.reportTotalIzin.toString(),
              icon: Icons.event_note_outlined,
              color: AppColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildReportSummaryCard(
              title: 'Total Sakit',
              value: controller.reportTotalSakit.toString(),
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
      () {
        final attendanceData = controller.reportAttendanceList;

        if (attendanceData.isEmpty) {
          return _buildEmptyReportState();
        }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Absensi (${attendanceData.length})',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
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
                        'Tanggal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Jam Masuk',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Jam Keluar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Status',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: attendanceData.map((attendance) {
                    final nama = attendance.user?.name ?? '-';
                    final npk = attendance.user?.npk ?? '-';
                    final tanggal = DateFormat('dd/MM/yyyy', 'id_ID').format(attendance.tanggal);
                    final jamMasuk = attendance.clockIn.isNotEmpty
                        ? attendance.clockIn.substring(0, attendance.clockIn.length >= 5 ? 5 : attendance.clockIn.length)
                        : '-';
                    final jamKeluar = attendance.clockOut?.isNotEmpty == true
                        ? attendance.clockOut!.substring(0, attendance.clockOut!.length >= 5 ? 5 : attendance.clockOut!.length)
                        : '-';
                    final status = _formatStatusDisplay(attendance.status);
                    final statusColor = _getStatusColor(attendance.status);

                    return DataRow(
                      cells: [
                        DataCell(Text(nama)),
                        DataCell(Text(npk, style: const TextStyle(fontFamily: 'monospace'))),
                        DataCell(Text(tanggal)),
                        DataCell(Text(jamMasuk)),
                        DataCell(Text(jamKeluar)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
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
        );
      },
    );
  }

  String _formatStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return 'Hadir';
      case 'terlambat':
        return 'Terlambat';
      case 'izin':
      case 'ijin':
        return 'Izin';
      case 'sakit':
        return 'Sakit';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'hadir':
        return AppColors.success;
      case 'terlambat':
        return AppColors.warning;
      case 'izin':
      case 'ijin':
        return AppColors.orange;
      case 'sakit':
        return AppColors.error;
      default:
        return AppColors.grey600;
    }
  }

  Widget _buildEmptyReportState() {
    return Container(
      padding: const EdgeInsets.all(48),
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assessment_outlined,
              size: 48,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Data Laporan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              'Data laporan untuk ${Get.find<AdminDashboardController>().reportMonthYearText} belum tersedia.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
