import 'package:get/get.dart';
import '../controllers/face_verification_controller.dart';

class FaceVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FaceVerificationController>(() => FaceVerificationController());
  }
}
