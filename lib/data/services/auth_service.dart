import 'package:get/get.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  void _loadUserFromStorage() {
    if (_storageService.isLoggedIn()) {
      final userData = _storageService.getUser();
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
        isLoggedIn.value = true;
      }
    }
  }

  Future<UserModel> login(String npk, String password, String role) async {
    try {
      // Mock API Delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock Login Logic
      // In a real app, this would be an API call via ApiProvider
      
      // Mock Data
      final userData = {
        'id': '1',
        'name': role == 'admin' ? 'Admin User' : 'Employee User',
        'email': '$npk@perhutani.co.id', // Generated email from NPK
        'role': role,
        'employee_id': npk,
        'department': 'Teknologi Informasi',
        'created_at': DateTime.now().toIso8601String(),
      };

      final user = UserModel.fromJson(userData);

      // Save to Storage
      await _storageService.saveUser(userData);
      await _storageService.saveToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await _storageService.setLoggedIn(true);

      // Update State
      currentUser.value = user;
      isLoggedIn.value = true;

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    currentUser.value = null;
    isLoggedIn.value = false;
    // Navigate to login is usually handled by the caller or a middleware/observer
  }
}
