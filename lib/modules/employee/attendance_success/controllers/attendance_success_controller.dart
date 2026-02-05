import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../routes/app_routes.dart';

class AttendanceSuccessController extends GetxController {
  final attendanceType = ''.obs;
  final isCheckIn = true.obs;
  final currentDate = ''.obs;
  final currentTime = ''.obs;
  final status = 'Tepat Waktu'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    isCheckIn.value = args?['isCheckIn'] ?? true;
    
    _setDateTime();
    _checkStatus();
  }

  void _setDateTime() {
    final now = DateTime.now();
    currentDate.value = DateFormat('dd/MM/yyyy').format(now);
    currentTime.value = DateFormat('HH:mm').format(now);
  }

  void _checkStatus() {
    final now = DateTime.now();
    final checkInLimit = DateTime(now.year, now.month, now.day, 8, 0); // 08:00
    
    if (isCheckIn.value && now.isAfter(checkInLimit)) {
      status.value = 'Terlambat';
    } else {
      status.value = 'Tepat Waktu';
    }
  }

  void goToDashboard() {
    Get.offAllNamed(AppRoutes.employeeDashboard);
  }
}
