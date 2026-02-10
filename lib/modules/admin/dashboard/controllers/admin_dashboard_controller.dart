import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../core/utils/logger.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/dashboard_attendance_model.dart';
import '../../../../data/models/employee_model.dart';
import '../../../../data/models/report_model.dart';
import 'mixins/dashboard_data_mixin.dart';
import 'mixins/employees_data_mixin.dart';
import 'mixins/reports_data_mixin.dart';

class AdminDashboardController extends GetxController
    with DashboardDataMixin, EmployeesDataMixin, ReportsDataMixin {
  final AuthService _authService = Get.find<AuthService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();

  // Loading state
  final isLoadingDashboard = false.obs;

  // Navigation
  final RxInt currentPageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateGreeting();
    loadDashboardData();
    loadEmployees();
    loadReports();
  }

  void _loadUserData() {
    // Observe user changes
    ever(_authService.currentUser, (user) {
      if (user != null) {
        userName.value = user.nama;
      }
    });

    // Initial load
    final currentUser = _authService.currentUser.value;
    if (currentUser != null) {
      userName.value = currentUser.nama;
    }
  }

  void _updateGreeting() {
    greeting.value = Helpers.getGreeting();
    final now = DateTime.now();
    currentDate.value = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
  }

  @override
  Future<void> loadDashboardData() async {
    isLoadingDashboard.value = true;

    try {
      // Get today's date in YYYY-MM-DD format
      final today = DateTime.now();
      final tanggal = DateFormat('yyyy-MM-dd').format(today);

      // Fetch today's attendance from API
      final result = await _attendanceService.getAttendanceByDate(
        tanggal: tanggal,
        perPage: 100,
      );

      if (result.isSuccess && result.data != null) {
        final attendances = result.data!;

        // Debug: log semua status untuk diagnosis
        for (var a in attendances) {
          AppLogger.info('Attendance: ${a.user?.name} - status: "${a.status}" (lowercase: "${a.status.toLowerCase()}")');
        }

        // Calculate totals dari SEMUA data absensi hari ini
        totalHadir.value = attendances.where((a) => _isStatus(a.status, 'hadir')).length;
        totalIzin.value = attendances.where((a) {
          final match = _isStatus(a.status, 'izin') || _isStatus(a.status, 'ijin');
          if (!match && a.status.toLowerCase().contains('i')) {
            // Log status yang mengandung 'i' tapi tidak match
            AppLogger.warning('Status with "i" but not matched: "${a.status}" for ${a.user?.name}');
          }
          return match;
        }).length;
        totalSakit.value = attendances.where((a) => _isStatus(a.status, 'sakit')).length;
        totalTerlambat.value = attendances.where((a) => _isStatus(a.status, 'terlambat')).length;

        // Build attendance list untuk display - SEMUA data tanpa batasan
        attendanceList.value = attendances.map((a) {
          return DashboardAttendanceModel(
            name: a.user?.name ?? 'Unknown',
            npk: a.user?.npk ?? '',
            date: DateFormat('dd/MM/yyyy').format(a.tanggal),
            jamMasuk: a.clockIn.substring(0, 5), // HH:mm
            status: _formatStatusDisplay(a.status),
            clockInImageUrl: a.clockInImageUrl,
            clockOutImageUrl: a.clockOutImageUrl,
          );
        }).toList();

        // Sync filtered list
        filteredAttendanceList.value = displayList;

        AppLogger.info('AdminDashboard: Loaded ${attendances.length} attendance records for today');
      } else {
        // Show error message
        if (result.error != null) {
          Get.snackbar(
            'Error',
            result.error!,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      AppLogger.error('AdminDashboard: Error loading dashboard data', e);
      Get.snackbar(
        'Error',
        'Gagal memuat data absensi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isLoadingDashboard.value = false;
    }
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

  /// Helper untuk cek status dengan case-insensitive
  bool _isStatus(String actualStatus, String expectedStatus) {
    return actualStatus.toLowerCase() == expectedStatus.toLowerCase();
  }

  @override
  Future<void> loadReports() async {
    // Mock data - replace with API
    reports.value = [
      ReportModel.createMock(
        name: 'Karyawan1',
        npk: 'NPK001',
        hadir: 20,
        izin: 1,
        sakit: 0,
        total: 21,
      ),
      ReportModel.createMock(
        name: 'Karyawan2',
        npk: 'NPK002',
        hadir: 18,
        izin: 2,
        sakit: 1,
        total: 21,
      ),
      ReportModel.createMock(
        name: 'Karyawan3',
        npk: 'NPK003',
        hadir: 19,
        izin: 0,
        sakit: 2,
        total: 21,
      ),
      ReportModel.createMock(
        name: 'Karyawan4',
        npk: 'NPK004',
        hadir: 21,
        izin: 0,
        sakit: 0,
        total: 21,
      ),
    ];
  }

  // Navigation
  void changeActivePage(int index) {
    currentPageIndex.value = index;
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
            child: const Text('Keluar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
