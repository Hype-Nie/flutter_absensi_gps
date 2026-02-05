import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_routes.dart';

class AdminDashboardController extends GetxController {
  final StorageService _storageService = Get.find();

  final greeting = ''.obs;
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _updateGreeting();
  }

  void _loadUserData() {
    final userData = _storageService.getUser();
    if (userData != null) {
      userName.value = userData['name'] ?? 'Admin';
    }
  }

  void _updateGreeting() {
    greeting.value = Helpers.getGreeting();
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _storageService.clearAll();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}
