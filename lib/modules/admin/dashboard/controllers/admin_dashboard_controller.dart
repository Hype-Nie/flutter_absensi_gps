import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/services/auth_service.dart';
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
  void loadDashboardData() {
    // Mock data - replace with API
    totalHadir.value = 45;
    totalIzin.value = 3;
    totalSakit.value = 2;

    attendanceList.value = [
      DashboardAttendanceModel.createMock(
        name: 'Karyawan1',
        date: '21/01/2026',
        jamMasuk: '08:00',
        status: 'Hadir',
      ),
      DashboardAttendanceModel.createMock(
        name: 'Karyawan2',
        date: '21/01/2026',
        jamMasuk: '08:00',
        status: 'Sakit',
      ),
      DashboardAttendanceModel.createMock(
        name: 'Karyawan3',
        date: '21/01/2026',
        jamMasuk: '08:00',
        status: 'Sakit',
      ),
    ];
  }

  @override
  void loadEmployees() {
    // Mock data - replace with API
    employees.value = [
      EmployeeModel.createMock(
        id: '1',
        name: 'Karyawan1',
        npk: 'NPK001',
        position: 'Staff',
        department: 'IT',
      ),
      EmployeeModel.createMock(
        id: '2',
        name: 'Karyawan2',
        npk: 'NPK002',
        position: 'Manager',
        department: 'HR',
      ),
      EmployeeModel.createMock(
        id: '3',
        name: 'Karyawan3',
        npk: 'NPK003',
        position: 'Staff',
        department: 'Finance',
      ),
      EmployeeModel.createMock(
        id: '4',
        name: 'Karyawan4',
        npk: 'NPK004',
        position: 'Staff',
        department: 'Marketing',
      ),
    ];
  }

  @override
  void loadReports() {
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
