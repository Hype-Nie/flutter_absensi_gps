import 'package:get/get.dart';
import '../../../../../../data/models/dashboard_attendance_model.dart';

mixin DashboardDataMixin on GetxController {
  // Dashboard Data
  final RxString greeting = ''.obs;
  final RxString userName = ''.obs;
  final RxString currentDate = ''.obs;
  final RxInt totalHadir = 0.obs;
  final RxInt totalIzin = 0.obs;
  final RxInt totalSakit = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxList<DashboardAttendanceModel> attendanceList = <DashboardAttendanceModel>[].obs;

  void loadDashboardData();
  void onSearch(String query) {
    searchQuery.value = query;
  }
}
