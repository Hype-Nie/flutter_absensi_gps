import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/attendance_success_controller.dart';

class AttendanceSuccessView extends GetView<AttendanceSuccessController> {
  const AttendanceSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.success.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.success,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 60,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Title
                    Obx(() => Text(
                      controller.isCheckIn.value
                          ? 'Absensi Masuk Berhasil'
                          : 'Absensi Keluar Berhasil',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    )),
                    const SizedBox(height: 40),

                    // Details
                    _buildDetailRow('Tanggal', controller.currentDate),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      controller.isCheckIn.value ? 'Jam Masuk' : 'Jam Keluar',
                      controller.currentTime,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Status', controller.status),
                    const SizedBox(height: 16),
                    
                    // Foto Selfie Row
                    Obx(() {
                      final localImage = controller.capturedImage.value;
                      final attendanceData = controller.attendanceData.value;
                      final imageUrl = attendanceData != null
                          ? (controller.isCheckIn.value
                              ? attendanceData.clockInImageUrl
                              : attendanceData.clockOutImageUrl)
                          : null;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Foto Selfi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey600,
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.grey200,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.grey300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: localImage != null
                                    ? Image.file(
                                        localImage,
                                        fit: BoxFit.cover,
                                      )
                                    : imageUrl != null
                                        ? Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.broken_image,
                                                color: AppColors.grey600,
                                                size: 32,
                                              );
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              );
                                            },
                                          )
                                        : const Icon(
                                            Icons.camera_alt_outlined,
                                            color: AppColors.grey600,
                                            size: 32,
                                          ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 40),

                    // Back to Dashboard Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.goToDashboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textWhite,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Kembali ke Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[300],
              width: double.infinity,
              alignment: Alignment.center,
              child: const Text(
                '@2026 Perhutani Padangan',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, RxString value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Obx(() => Text(
            value.value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          )),
        ],
      ),
    );
  }
}
