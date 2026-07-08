import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/attendance_service.dart';
import '../../../../data/models/attendance_history_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../routes/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ML Kit helper — pure functions, no state, no Get dependency
// ponytail: tidak perlu file/class terpisah, tidak dipakai di modul lain
// ─────────────────────────────────────────────────────────────────────────────
class _FaceDetectorHelper {
  final FaceDetector detector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  Future<List<Face>> detect(CameraImage image, CameraDescription camera) async {
    final inputImage = _toInputImage(image, camera);
    return detector.processImage(inputImage);
  }

  InputImage _toInputImage(CameraImage image, CameraDescription camera) {
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation)
        ?? InputImageRotation.rotation0deg;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // ponytail: nv21 on Android, bgra8888 on iOS — both supported by ML Kit
    if (format == null || image.planes.isEmpty) {
      throw UnsupportedError('Unsupported image format: ${image.format.raw}');
    }
    return InputImage.fromBytes(
      bytes: Uint8List.fromList(image.planes.expand((p) => p.bytes).toList()),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Future<void> close() => detector.close();
}

// ─────────────────────────────────────────────────────────────────────────────
enum FaceStep { lookRight, lookLeft, smile, capture }

class FaceVerificationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final AttendanceService _attendanceService = Get.find<AttendanceService>();
  final SecurityService _securityService = Get.find<SecurityService>();

  // ── args from GPS ──
  final attendanceType = ''.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final accurateTime = Rxn<DateTime>();
  final isClockOut = false.obs;
  final isOutsideLocation = false.obs;

  // ── submission state ──
  final isLoading = false.obs;
  final canSubmit = true.obs;
  final timeUntilCanSubmit = ''.obs;
  final todayAttendance = Rxn<AttendanceHistoryModel>();
  final capturedImage = Rxn<File>();

  // ── face verification state ──
  final currentStep = FaceStep.lookRight.obs;
  final stableFrames = 0.obs;
  final isCapturing = false.obs;
  final stepsDone = <FaceStep>[].obs;

  CameraController? cameraController;
  final _mlKit = _FaceDetectorHelper();

  // ponytail: thresholds from CONTEXT DUMP
  static const yawRight = 45.0;
  static const yawLeft = 45.0;
  static const smileThreshold = 0.7;
  static const stableRequired = 10;

  // ── frame processing guard — bool flag is safe (single isolate) ──
  bool _processingFrame = false;

  @override
  void onInit() {
    super.onInit();
    _readArgs();
    _initCamera();
  }

  void _readArgs() {
    final args = Get.arguments as Map<String, dynamic>?;
    attendanceType.value = args?['type'] ?? 'hadir';
    latitude.value = args?['latitude'] ?? 0.0;
    longitude.value = args?['longitude'] ?? 0.0;
    isClockOut.value = args?['isClockOut'] ?? false;
    isOutsideLocation.value = args?['isOutsideLocation'] ?? false;
    if (args?['accurateTime'] != null) {
      accurateTime.value = args!['accurateTime'] as DateTime;
    }
    _checkTodayAttendance();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );
    cameraController = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await cameraController!.initialize();
    cameraController!.startImageStream(_onFrame);
    update();
  }

  // ── frame handler ─────────────────────────────────────────────────────────
  void _onFrame(CameraImage image) {
    if (_processingFrame || isCapturing.value) return;
    _processingFrame = true;
    // ponytail: always reset flag in finally — one bad frame cannot freeze stream
    _detectFace(image).whenComplete(() => _processingFrame = false);
  }

  Future<void> _detectFace(CameraImage image) async {
    try {
      final faces = await _mlKit.detect(image, cameraController!.description);
      if (faces.isEmpty) {
        stableFrames.value = 0;
        return;
      }
      _evaluateStep(faces.first);
    } catch (e) {
      // ponytail: log but never rethrow — whenComplete() resets flag regardless
      AppLogger.error('FaceDetector frame error', e);
    }
  }

  void _evaluateStep(Face face) {
    final yaw = face.headEulerAngleY ?? 0;
    final smile = face.smilingProbability ?? 0;

    // ponytail: front camera mirrors X-axis → yaw sign inverted vs real world
    final bool match = switch (currentStep.value) {
      FaceStep.lookRight => yaw < -yawRight, // user right = ML Kit negative yaw
      FaceStep.lookLeft  => yaw > yawLeft,   // user left  = ML Kit positive yaw
      FaceStep.smile     => smile > smileThreshold,
      FaceStep.capture   => false,
    };

    if (match) {
      stableFrames.value++;
      if (stableFrames.value >= stableRequired) _advanceStep();
    } else {
      stableFrames.value = 0;
    }
  }

  void _advanceStep() {
    final done = currentStep.value;
    stepsDone.add(done);
    stableFrames.value = 0;
    
    if (done == FaceStep.smile) {
      currentStep.value = FaceStep.capture;
      _autoCapture();
      return;
    }
    
    currentStep.value = switch (done) {
      FaceStep.lookRight => FaceStep.lookLeft,
      FaceStep.lookLeft  => FaceStep.smile,
      _                  => FaceStep.capture,
    };
  }

  // ── capture & submit ──────────────────────────────────────────────────────
  Future<void> _autoCapture() async {
    if (isCapturing.value) return;
    isCapturing.value = true;
    try {
      // Guard: stream may already be stopped (e.g. app backgrounded)
      if (cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }
      final xfile = await cameraController!.takePicture();
      capturedImage.value = File(xfile.path);
      
      // Verify face
      final (success, errorMsg) = await _authService.verifyFace(capturedImage.value!);
      if (!success) {
        Get.snackbar('Gagal', errorMsg ?? 'Wajah tidak cocok',
            backgroundColor: AppColors.error, colorText: Colors.white);
        capturedImage.value = null;
        stepsDone.clear();
        currentStep.value = FaceStep.lookRight;
        isCapturing.value = false;
        if (cameraController?.value.isInitialized == true) {
          cameraController!.startImageStream(_onFrame);
        }
        return;
      }

      await submitAttendance();
    } catch (e) {
      isCapturing.value = false;
      Get.snackbar('Error', 'Gagal memproses foto: $e',
          backgroundColor: AppColors.error, colorText: Colors.white);
      // Restart stream only if camera is still initialized
      if (cameraController?.value.isInitialized == true &&
          !cameraController!.value.isStreamingImages) {
        cameraController!.startImageStream(_onFrame);
      }
    }
  }

  // ── attendance (ported 1:1 from PhotoValidationController) ───────────────
  Future<void> _checkTodayAttendance() async {
    final user = _authService.currentUser.value;
    if (user == null) return;
    final att = await _attendanceService.getTodayAttendance(user.id);
    if (att != null) {
      todayAttendance.value = att;
      if (att.clockOut == null) {
        isClockOut.value = true;
        await _validateClockOutTime();
      }
    }
  }

  Future<void> _validateClockOutTime() async {
    try {
      final now = await _securityService.getAccurateTime();
      final nineAM = DateTime(now.year, now.month, now.day, 9);
      if (now.isAfter(nineAM) || now.isAtSameMomentAs(nineAM)) {
        canSubmit.value = true;
      } else {
        canSubmit.value = false;
        timeUntilCanSubmit.value =
            'Clock out hanya bisa setelah jam 09:00. Tunggu ${nineAM.difference(now).inMinutes} menit lagi';
        Future.delayed(const Duration(minutes: 1), _validateClockOutTime);
      }
    } catch (_) {
      canSubmit.value = true; // NTP fail → allow (SecurityService handles logging)
    }
  }

  Future<void> submitAttendance() async {
    if (capturedImage.value == null) return;
    if (!canSubmit.value) {
      Get.snackbar('Perhatian', timeUntilCanSubmit.value,
          backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }
    final user = _authService.currentUser.value;
    if (user == null) {
      Get.snackbar('Error', 'User tidak ditemukan. Silakan login kembali',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final result = isClockOut.value && todayAttendance.value != null
          ? await _attendanceService.clockOut(
              attendanceId: todayAttendance.value!.id,
              clockOutImage: capturedImage.value!,
              clockOutLat: latitude.value,
              clockOutLong: longitude.value,
            )
          : await _attendanceService.clockIn(
              userId: user.id,
              tanggal: accurateTime.value ?? await _securityService.getAccurateTime(),
              clockInImage: capturedImage.value!,
              clockInLat: latitude.value,
              clockInLong: longitude.value,
              status: isOutsideLocation.value ? 'menunggu_konfirmasi' : null,
            );

      isLoading.value = false;

      if (result.isSuccess && result.data != null) {
        Get.offNamed(AppRoutes.employeeAttendanceSuccess, arguments: {
          'type': attendanceType.value,
          'isCheckIn': !isClockOut.value,
          'attendanceData': result.data,
          'capturedImage': capturedImage.value,
          'accurateTime': accurateTime.value,
        });
      } else {
        Get.dialog(AlertDialog(
          title: const Text('Error'),
          content: SingleChildScrollView(
              child: Text(result.error ?? 'Gagal menyimpan absensi')),
          actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
        ));
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Terjadi kesalahan: $e',
          backgroundColor: AppColors.error, colorText: Colors.white);
    }
  }

  // ── dispose ───────────────────────────────────────────────────────────────
  @override
  void onClose() {
    // Stop stream before dispose — guard against already-stopped state
    final cam = cameraController;
    if (cam != null && cam.value.isInitialized) {
      if (cam.value.isStreamingImages) {
        cam.stopImageStream().catchError((_) {}); // fire-and-forget, non-fatal
      }
      cam.dispose();
    }
    _mlKit.close(); // closes FaceDetector native resources
    super.onClose();
  }
}
