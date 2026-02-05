import 'package:get/get.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final StorageService _storageService = Get.find();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Check if user is logged in
    final isLoggedIn = _storageService.isLoggedIn();
    final userData = _storageService.getUser();

    if (isLoggedIn && userData != null) {
      // Navigate based on user role
      final role = userData['role'];
      if (role == 'admin') {
        Get.offAllNamed(AppRoutes.adminDashboard);
      } else {
        Get.offAllNamed(AppRoutes.employeeDashboard);
      }
    } else {
      // Navigate to login
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
