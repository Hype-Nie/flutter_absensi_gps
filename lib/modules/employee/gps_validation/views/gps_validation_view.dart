import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/gps_validation_controller.dart';

class GpsValidationView extends GetView<GpsValidationController> {
  const GpsValidationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMapArea(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Get.back(),
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          const Text(
            'Validasi GPS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: _buildMapContainer(),
          ),
          const SizedBox(height: 24),
          _buildLocationInfo(),
          _buildCoordinates(),
          const SizedBox(height: 32),
          _buildValidateButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Stack(
        children: [
          // Map background pattern
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CustomPaint(
              size: Size.infinite,
              painter: const _MapPatternPainter(),
            ),
          ),
          // Location pin
          const Center(
            child: _LocationPin(),
          ),
          // Loading indicator
          Obx(() => controller.isLoading.value
              ? Container(
                  color: AppColors.surface.withValues(alpha: 0.7),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink()),
          // Refresh button
          const Positioned(
            top: 12,
            right: 12,
            child: _MapRefreshButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Obx(() => Text(
      controller.currentPosition.value != null
          ? 'Pastikan Anda berada di lokasi yang sesuai\nuntuk melakukan absensi'
          : 'Menunggu lokasi GPS...',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.5,
      ),
    ));
  }

  Widget _buildCoordinates() {
    return Obx(() {
      final position = controller.currentPosition.value;
      if (position != null) {
        return Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            'Lat: ${position.latitude.toStringAsFixed(6)}, '
            'Lng: ${position.longitude.toStringAsFixed(6)}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildValidateButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isLoading.value
            ? null
            : controller.validateLocation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.grey800,
          foregroundColor: AppColors.textWhite,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColors.grey400,
        ),
        child: controller.isLoading.value
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textWhite,
                ),
              )
            : const Text(
                'Validasi Lokasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      )),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.grey300,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Text(
        '@2026 Perhutani Padangan',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  const _LocationPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.location_on,
            size: 40,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

class _MapRefreshButton extends StatelessWidget {
  const _MapRefreshButton();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GpsValidationController>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: controller.refreshLocation,
      ),
    );
  }
}

// Custom painter for map-like pattern
class _MapPatternPainter extends CustomPainter {
  const _MapPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines to simulate map
    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }

    // Draw some "roads"
    final roadPaint = Paint()
      ..color = AppColors.grey400
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width / 4, 0),
      Offset(size.width / 4, size.height),
      roadPaint..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      roadPaint..strokeWidth = 4,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
