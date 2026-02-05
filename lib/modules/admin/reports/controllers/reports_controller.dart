import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReportsController extends GetxController {
  final isLoading = false.obs;
  final selectedMonth = DateTime.now().obs;
  final reports = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadReports();
  }

  void _loadReports() {
    // Mock data - replace with API
    reports.value = [
      {
        'name': 'Karyawan1',
        'npk': 'NPK001',
        'hadir': 20,
        'izin': 1,
        'sakit': 0,
        'total': 21,
      },
      {
        'name': 'Karyawan2',
        'npk': 'NPK002',
        'hadir': 18,
        'izin': 2,
        'sakit': 1,
        'total': 21,
      },
      {
        'name': 'Karyawan3',
        'npk': 'NPK003',
        'hadir': 19,
        'izin': 0,
        'sakit': 2,
        'total': 21,
      },
      {
        'name': 'Karyawan4',
        'npk': 'NPK004',
        'hadir': 21,
        'izin': 0,
        'sakit': 0,
        'total': 21,
      },
    ];
  }

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
      _loadReports();
    }
  }

  void exportReport() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download, color: Colors.green),
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
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Excel (.xlsx)'),
              onTap: () {
                Get.back();
                _performExport('excel');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('PDF (.pdf)'),
              onTap: () {
                Get.back();
                _performExport('pdf');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _performExport(String format) {
    isLoading.value = true;
    
    // Simulate export
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      Get.snackbar(
        'Berhasil',
        'Laporan berhasil diexport dalam format ${format.toUpperCase()}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  void goBack() {
    Get.back();
  }
}
