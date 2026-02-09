import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../../data/models/report_model.dart';

mixin ReportsDataMixin on GetxController {
  // Reports Page Data
  final RxBool isLoadingReports = false.obs;
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxList<ReportModel> reports = <ReportModel>[].obs;

  Future<void> loadReports();

  String get monthYearText {
    return DateFormat('MMMM yyyy', 'id_ID').format(selectedMonth.value);
  }

  void selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      selectedMonth.value = picked;
      loadReports();
    }
  }

  void exportReport() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download, color: AppColors.success),
            SizedBox(width: 8),
            Text('Export Laporan'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih format export:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.success),
              title: const Text('Excel (.xlsx)'),
              onTap: () {
                Get.back();
                performExport('excel');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text('PDF (.pdf)'),
              onTap: () {
                Get.back();
                performExport('pdf');
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ],
      ),
    );
  }

  void performExport(String format) {
    isLoadingReports.value = true;

    // Simulate export
    Future.delayed(const Duration(seconds: 2), () {
      isLoadingReports.value = false;
      Get.snackbar(
        'Berhasil',
        'Laporan berhasil diexport dalam format ${format.toUpperCase()}',
        backgroundColor: AppColors.success,
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.TOP,
      );
    });
  }
}
