import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_routes.dart';

class AdminDashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Navigation
  final currentPageIndex = 0.obs;

  // Dashboard Data
  final greeting = ''.obs;
  final userName = ''.obs;
  final currentDate = ''.obs;
  final totalHadir = 0.obs;
  final totalIzin = 0.obs;
  final totalSakit = 0.obs;
  final searchQuery = ''.obs;
  final attendanceList = <Map<String, dynamic>>[].obs;

  // Employees Page Data
  final employeeSearchQuery = ''.obs;
  final employees = <Map<String, dynamic>>[].obs;
  final isLoadingEmployees = false.obs;

  // Reports Page Data
  final isLoadingReports = false.obs;
  final selectedMonth = DateTime.now().obs;
  final reports = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateGreeting();
    _loadDashboardData();
    _loadEmployees();
    _loadReports();
  }

  void _loadUserData() {
    // Observe user changes
    ever(_authService.currentUser, (user) {
      if (user != null) {
        userName.value = user.nama;
      }
    });

    // Initial load
    if (_authService.currentUser.value != null) {
      userName.value = _authService.currentUser.value!.nama;
    }
  }

  void _updateGreeting() {
    greeting.value = Helpers.getGreeting();
    final now = DateTime.now();
    currentDate.value = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
  }

  void _loadDashboardData() {
    // Mock data - replace with API
    totalHadir.value = 45;
    totalIzin.value = 3;
    totalSakit.value = 2;

    attendanceList.value = [
      {
        'name': 'Karyawan1',
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '-',
        'status': 'Hadir',
      },
      {
        'name': 'Karyawan2',
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '-',
        'status': 'Sakit',
      },
      {
        'name': 'Karyawan3',
        'date': '21/01/2026',
        'jamMasuk': '08:00',
        'jamKeluar': '-',
        'status': 'Sakit',
      },
    ];
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

  // Navigation Methods
  void changeActivePage(int index) {
    currentPageIndex.value = index;
  }

  // Dashboard Methods
  void onSearch(String query) {
    searchQuery.value = query;
  }

  // Employees Page Methods
  List<Map<String, dynamic>> get filteredEmployees {
    if (employeeSearchQuery.value.isEmpty) {
      return employees;
    }
    return employees.where((emp) {
      final name = emp['name']?.toString().toLowerCase() ?? '';
      final npk = emp['npk']?.toString().toLowerCase() ?? '';
      final query = employeeSearchQuery.value.toLowerCase();
      return name.contains(query) || npk.contains(query);
    }).toList();
  }

  void onEmployeeSearch(String query) {
    employeeSearchQuery.value = query;
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
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
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

  // Reports Page Methods
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
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
        ],
      ),
    );
  }

  void _performExport(String format) {
    isLoadingReports.value = true;

    // Simulate export
    Future.delayed(const Duration(seconds: 2), () {
      isLoadingReports.value = false;
      Get.snackbar(
        'Berhasil',
        'Laporan berhasil diexport dalam format ${format.toUpperCase()}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    });
  }

  // Logout
  void logout() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await _authService.logout();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
