import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';

/// EmotionDetectionController — deteksi emosi wajah menggunakan AI Backend (DeepFace)
///
/// Cara kerja:
///   1. Buka kamera depan
///   2. Setiap 3 detik, ambil foto (takePicture)
///   3. Konversi foto ke base64
///   4. Kirim ke API Flask (/emotion/predict) yang menggunakan DeepFace + MediaPipe
///   5. Tampilkan hasil prediksi di layar
///   6. Tombol "Simpan" → kirim ke Flask API (/emotion) untuk masuk ke database
class EmotionDetectionController extends GetxController {
  // ── State yang diobservasi oleh View ──────────────────────
  final detectedEmotion = 'Mendeteksi...'.obs;
  final confidence = 0.0.obs;
  final isDetecting = false.obs;
  final isSaving = false.obs;
  final cameraReady = false.obs;
  final errorMessage = ''.obs;

  // ── Internal ──────────────────────────────────────────────
  CameraController? cameraController;
  Timer? _timer;
  bool _isProcessingFrame = false;

  @override
  void onInit() {
    super.onInit();
    _initCamera();
  }

  @override
  void onClose() {
    _timer?.cancel();
    cameraController?.dispose();
    super.onClose();
  }

  // ── Init kamera depan ─────────────────────────────────────
  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      cameraReady.value = true;

      // Mulai mengambil foto setiap 3 detik untuk dikirim ke Backend
      _startDetectionTimer();
    } catch (e) {
      errorMessage.value = 'Gagal membuka kamera: $e';
    }
  }

  void _startDetectionTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _processImage();
    });
  }

  // ── Ambil gambar dan kirim ke API Flask (DeepFace) ────────
  Future<void> _processImage() async {
    if (_isProcessingFrame || !cameraReady.value || cameraController == null) {
      return;
    }
    
    if (!cameraController!.value.isInitialized || cameraController!.value.isTakingPicture) {
      return;
    }

    _isProcessingFrame = true;

    try {
      // Ambil foto dari kamera
      final XFile image = await cameraController!.takePicture();
      
      // Ubah ke format Base64
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      // Kirim ke API Flask (/emotion/predict)
      final result = await ApiService.predictEmotion(base64String);

      if (result['success'] == true) {
        detectedEmotion.value = result['emotion'] as String;
        // Backend mengembalikan confidence sebagai int/double (misal: 98.5)
        confidence.value = (result['confidence'] as num).toDouble();
      } else {
        detectedEmotion.value = 'Wajah tidak terdeteksi';
        confidence.value = 0.0;
      }
    } catch (e) {
      // Jika error (misal: wajah tidak ada atau jaringan lambat), kembalikan ke state awal
      detectedEmotion.value = 'Mendeteksi...';
      confidence.value = 0.0;
    } finally {
      _isProcessingFrame = false;
    }
  }

  // ── Simpan hasil ke backend ───────────────────────────────
  Future<void> saveDetection() async {
    if (detectedEmotion.value == 'Mendeteksi...' ||
        detectedEmotion.value == 'Wajah tidak terdeteksi') {
      Get.snackbar('Info', 'Posisikan wajah kamu di depan kamera',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSaving.value = true;
    try {
      await ApiService.saveEmotion(
        emotionLabel: detectedEmotion.value,
        confidence: confidence.value,
      );
      Get.snackbar(
        'Tersimpan',
        'Emosi "${detectedEmotion.value}" berhasil dicatat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE8F5E9),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}
