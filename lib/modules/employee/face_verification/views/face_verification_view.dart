import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/face_verification_controller.dart';

class FaceVerificationView extends GetView<FaceVerificationController> {
  const FaceVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Verifikasi Wajah'),
        centerTitle: true,
      ),
      body: GetBuilder<FaceVerificationController>(
        builder: (_) {
          final cam = controller.cameraController;
          if (cam == null || !cam.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return Column(
            children: [
              Expanded(child: _CameraOverlay(controller: controller)),
              _StepPanel(controller: controller),
            ],
          );
        },
      ),
    );
  }
}

// ── Camera preview with oval face guide ──────────────────────────────────────

class _CameraOverlay extends StatelessWidget {
  const _CameraOverlay({required this.controller});
  final FaceVerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller.cameraController!),
        // Semi-opaque surround so the oval "cutout" pops
        CustomPaint(painter: _OvalHolePainter()),
        // Step instruction text
        Positioned(
          top: 24,
          left: 0,
          right: 0,
          child: Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _InstructionBadge(
                  key: ValueKey(controller.currentStep.value),
                  step: controller.currentStep.value,
                  stableFrames: controller.stableFrames.value,
                ),
              )),
        ),
      ],
    );
  }
}

class _OvalHolePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.72,
      height: size.height * 0.55,
    );
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.55));

    // Oval border
    canvas.drawOval(
      ovalRect,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _InstructionBadge extends StatelessWidget {
  const _InstructionBadge({super.key, required this.step, required this.stableFrames});
  final FaceStep step;
  final int stableFrames;

  @override
  Widget build(BuildContext context) {
    final (icon, text) = switch (step) {
      FaceStep.lookRight => (Icons.arrow_forward, 'Tengok ke kanan'),
      FaceStep.lookLeft => (Icons.arrow_back, 'Tengok ke kiri'),
      FaceStep.smile => (Icons.sentiment_satisfied_alt, 'Tersenyum'),
      FaceStep.capture => (Icons.camera_alt, 'Tekan tombol ambil foto'),
    };
    // Simple progress dots for stable-frame feedback
    final progress = (stableFrames / FaceVerificationController.stableRequired).clamp(0.0, 1.0);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ),
        if (step != FaceStep.capture) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white30,
              color: Colors.greenAccent,
              minHeight: 4,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Bottom panel: checklist + capture button ─────────────────────────────────

class _StepPanel extends StatelessWidget {
  const _StepPanel({required this.controller});
  final FaceVerificationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Obx(() {
        final done = controller.stepsDone;
        final current = controller.currentStep.value;
        final loading = controller.isLoading.value || controller.isCapturing.value;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CheckRow(
              icon: Icons.arrow_forward,
              label: 'Tengok kanan',
              done: done.contains(FaceStep.lookRight),
              active: current == FaceStep.lookRight,
            ),
            _CheckRow(
              icon: Icons.arrow_back,
              label: 'Tengok kiri',
              done: done.contains(FaceStep.lookLeft),
              active: current == FaceStep.lookLeft,
            ),
            _CheckRow(
              icon: Icons.sentiment_satisfied_alt,
              label: 'Senyum',
              done: done.contains(FaceStep.smile),
              active: current == FaceStep.smile,
            ),
            _CheckRow(
              icon: Icons.camera_alt,
              label: 'Verifikasi wajah',
              done: done.contains(FaceStep.capture),
              active: current == FaceStep.capture,
            ),
            const SizedBox(height: 16),
            if (loading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(strokeWidth: 2, color: Colors.greenAccent),
                    SizedBox(height: 8),
                    Text('Memverifikasi wajah...', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              )
            else
              const SizedBox(height: 52), // placeholder to maintain height
          ],
        );
      }),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.icon,
    required this.label,
    required this.done,
    required this.active,
  });
  final IconData icon;
  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? Colors.greenAccent
        : active
            ? Colors.white
            : Colors.grey[600]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : (active ? Icons.radio_button_checked : Icons.radio_button_unchecked),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 14)),
        ],
      ),
    );
  }
}
