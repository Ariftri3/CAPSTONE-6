import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../services/api_service.dart';

/// EmotionDetectionController — deteksi emosi wajah secara real-time
/// menggunakan kamera depan + Google ML Kit Face Detection.
///
/// Cara kerja:
///   1. Buka kamera depan
///   2. Setiap frame dianalisis: deteksi landmark wajah (senyum, mata terbuka)
///   3. Dari nilai tersebut, klasifikasikan ke label emosi
///   4. Tampilkan hasil live di layar
///   5. Tombol "Simpan" → kirim ke Flask API (/emotion)
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
  late FaceDetector _faceDetector;
  bool _isProcessingFrame = false;

  @override
  void onInit() {
    super.onInit();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,  // aktifkan senyum & mata terbuka
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _initCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    _faceDetector.close();
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
        imageFormatGroup: ImageFormatGroup.nv21, // Android
      );

      await cameraController!.initialize();
      cameraReady.value = true;

      // Mulai stream frame untuk deteksi real-time
      cameraController!.startImageStream(_processFrame);
    } catch (e) {
      errorMessage.value = 'Gagal membuka kamera: $e';
    }
  }

  // ── Proses setiap frame dari kamera ──────────────────────
  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessingFrame) return;
    _isProcessingFrame = true;

    try {
      final inputImage = _toInputImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        detectedEmotion.value = 'Wajah tidak terdeteksi';
        confidence.value = 0;
        return;
      }

      // Ambil wajah pertama yang terdeteksi
      final face = faces.first;
      final result = _classifyEmotion(face);
      detectedEmotion.value = result['label'] as String;
      confidence.value = result['confidence'] as double;
    } catch (_) {
      // abaikan error per-frame supaya stream tetap jalan
    } finally {
      _isProcessingFrame = false;
    }
  }

  // ── Klasifikasi emosi dari landmark wajah ─────────────────
  /// ML Kit memberikan nilai probabilitas senyum (0-1) dan mata terbuka (0-1).
  /// Kita gunakan kombinasi nilai itu untuk menentukan emosi.
  Map<String, dynamic> _classifyEmotion(Face face) {
    final smileProb = face.smilingProbability ?? 0.0;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    final eyeOpen = (leftEyeOpen + rightEyeOpen) / 2;

    String label;
    double conf;

    if (smileProb > 0.75) {
      label = 'Bahagia';
      conf = smileProb * 100;
    } else if (smileProb > 0.45) {
      label = 'Tenang';
      conf = (smileProb + 0.2).clamp(0.0, 1.0) * 100;
    } else if (eyeOpen < 0.3) {
      label = 'Lelah';
      conf = (1 - eyeOpen) * 100;
    } else if (smileProb < 0.15 && eyeOpen > 0.7) {
      label = 'Sedih';
      conf = (1 - smileProb) * 80;
    } else if (smileProb < 0.25) {
      label = 'Netral';
      conf = 70.0;
    } else {
      label = 'Cemas';
      conf = 65.0;
    }

    return {'label': label, 'confidence': double.parse(conf.toStringAsFixed(1))};
  }

  // ── Konversi CameraImage → InputImage untuk ML Kit ────────
  InputImage? _toInputImage(CameraImage image) {
    final camera = cameraController?.description;
    if (camera == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(
          camera.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: Uint8List.fromList(
        image.planes.expand((p) => p.bytes).toList(),
      ),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
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
        backgroundColor: Color(0xFFE8F5E9),
      );
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSaving.value = false;
    }
  }
}
