import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'emotion_detection_controller.dart';

class EmotionDetectionView extends GetView<EmotionDetectionController> {
  const EmotionDetectionView({super.key});

  // Mapping label emosi ke emoji
  String _emoji(String label) {
    switch (label) {
      case 'Bahagia':  return '😊';
      case 'Tenang':   return '😌';
      case 'Sedih':    return '😢';
      case 'Lelah':    return '😴';
      case 'Cemas':    return '😰';
      case 'Netral':   return '😐';
      default:         return '🔍';
    }
  }

  Color _emotionColor(String label) {
    switch (label) {
      case 'Bahagia':  return const Color(0xFF4CAF50);
      case 'Tenang':   return const Color(0xFF2196F3);
      case 'Sedih':    return const Color(0xFF9C27B0);
      case 'Lelah':    return const Color(0xFF607D8B);
      case 'Cemas':    return const Color(0xFFFF9800);
      case 'Netral':   return const Color(0xFF795548);
      default:         return AppTheme.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: const Text('Deteksi Emosi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      backgroundColor: AppTheme.primaryLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Preview kamera live ──────────────────────────────
            Obx(() {
              if (controller.errorMessage.value.isNotEmpty) {
                return _cameraPlaceholder(
                  icon: Icons.error_outline,
                  text: controller.errorMessage.value,
                  color: Colors.red,
                  actionLabel: controller.permissionPermanentlyDenied.value
                      ? 'Buka Pengaturan'
                      : 'Coba Lagi',
                  onAction: controller.permissionPermanentlyDenied.value
                      ? controller.openSettings
                      : controller.retry,
                );
              }
              if (!controller.cameraReady.value) {
                return _cameraPlaceholder(
                  icon: Icons.camera_alt,
                  text: 'Membuka kamera...',
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: AspectRatio(
                  aspectRatio: 4 / 4.2,
                  child: CameraPreview(controller.cameraController!),
                ),
              );
            }),

            const SizedBox(height: 20),

            // ── Hasil deteksi emosi ──────────────────────────────
            Obx(() {
              final emotion = controller.detectedEmotion.value;
              final conf = controller.confidence.value;
              final color = _emotionColor(emotion);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Ikon emosi + warna dinamis
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(_emoji(emotion),
                            style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emotion,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            conf > 0
                                ? '${conf.toStringAsFixed(1)}% akurasi'
                                : 'Menunggu wajah...',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[600]),
                          ),
                          if (conf > 0) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: conf / 100,
                                backgroundColor: Colors.grey[200],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // ── Tombol Simpan ─────────────────────────────────────
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveDetection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: controller.isSaving.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_alt, color: Colors.white),
                  label: Text(
                    controller.isSaving.value ? 'Menyimpan...' : 'Simpan Hasil',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _cameraPlaceholder({
    required IconData icon,
    required String text,
    Color color = AppTheme.primaryBlue,
    String? actionLabel,
    VoidCallback? onAction,
  }) =>
      Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                ),
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      );
}
