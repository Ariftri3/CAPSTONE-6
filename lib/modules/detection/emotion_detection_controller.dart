import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/api_service.dart';

/// EmotionDetectionController — deteksi emosi wajah secara real-time
/// menggunakan kamera depan + Google ML Kit Face Detection.
///
/// Cara kerja:
///   1. Minta izin kamera (jika belum diberikan)
///   2. Buka kamera depan
///   3. Setiap frame dianalisis: deteksi landmark wajah (senyum, mata terbuka)
///   4. Dari nilai tersebut, klasifikasikan ke label emosi
///   5. Tampilkan hasil live di layar — begitu wajah diarahkan ke kamera,
///      hasil deteksi langsung diperbarui tanpa perlu menekan tombol apa pun
///   6. Tombol "Simpan" → kirim ke Flask API (/emotion)
class EmotionDetectionController extends GetxController
    with WidgetsBindingObserver {
  // ── State yang diobservasi oleh View ──────────────────────
  final detectedEmotion = 'Mendeteksi...'.obs;
  final confidence = 0.0.obs;
  final isDetecting = false.obs;
  final isSaving = false.obs;
  final cameraReady = false.obs;
  final errorMessage = ''.obs;
  final permissionPermanentlyDenied = false.obs;

  // ── Internal ──────────────────────────────────────────────
  CameraController? cameraController;
  FaceDetector? _faceDetector;
  bool _isProcessingFrame = false;
  bool _isDisposing = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // aktifkan senyum & mata terbuka
        enableLandmarks: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _setupCamera();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposing = true;
    cameraController?.dispose();
    _faceDetector?.close();
    super.onClose();
  }

  // Jeda/nyalakan ulang stream kamera saat app di-background/foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cam = cameraController;
    if (cam == null || !cam.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      if (cam.value.isStreamingImages) {
        cam.stopImageStream();
      }
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  // ── Minta izin lalu buka kamera depan ─────────────────────
  Future<void> _setupCamera() async {
    errorMessage.value = '';
    permissionPermanentlyDenied.value = false;

    // 1) Pastikan izin kamera diberikan
    final status = await Permission.camera.request();

    if (status.isPermanentlyDenied) {
      permissionPermanentlyDenied.value = true;
      errorMessage.value =
          'Izin kamera ditolak permanen. Aktifkan lewat Pengaturan aplikasi.';
      return;
    }
    if (!status.isGranted) {
      errorMessage.value =
          'Izin kamera diperlukan agar fitur deteksi emosi bisa berjalan.';
      return;
    }

    await _initCamera();
  }

  // ── Init kamera depan ─────────────────────────────────────
  Future<void> _initCamera() async {
    try {
      // Jika sudah ada controller sebelumnya (mis. resume dari background),
      // buang dulu supaya tidak dobel.
      if (cameraController != null) {
        await cameraController!.dispose();
        cameraController = null;
        cameraReady.value = false;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage.value = 'Tidak ada kamera yang tersedia di perangkat ini';
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        // Android butuh NV21, iOS/macOS butuh BGRA8888 agar bisa dibaca ML Kit
        imageFormatGroup:
            Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      cameraController = controller;
      await controller.initialize();

      if (_isDisposing) return; // controller sudah ditutup sebelum init selesai

      cameraReady.value = true;
      detectedEmotion.value = 'Arahkan wajah ke kamera...';
      isDetecting.value = true;

      // Mulai stream frame untuk deteksi real-time
      await controller.startImageStream(_processFrame);
    } on CameraException catch (e) {
      errorMessage.value = 'Gagal membuka kamera: ${e.description ?? e.code}';
    } catch (e) {
      errorMessage.value = 'Gagal membuka kamera: $e';
    }
  }

  // Dipanggil dari tombol "Coba Lagi" di UI kalau kamera gagal terbuka
  Future<void> retry() => _setupCamera();

  Future<void> openSettings() => openAppSettings();

  // ── Proses setiap frame dari kamera ──────────────────────
  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessingFrame || _isDisposing || _faceDetector == null) return;
    _isProcessingFrame = true;

    try {
      final inputImage = _toInputImage(image);
      if (inputImage == null) return;

      final faces = await _faceDetector!.processImage(inputImage);

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

    // Sensor orientation dikombinasikan dengan orientasi device agar
    // preview & hasil deteksi tetap sinkron di semua rotasi layar.
    final rotationCompensation = _rotationIntToImageRotation(
      camera.sensorOrientation,
    );

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    // Untuk nv21/bgra8888, seluruh data ada di satu plane.
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: Uint8List.fromList(plane.bytes),
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotationCompensation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  InputImageRotation _rotationIntToImageRotation(int rotation) {
    return InputImageRotationValue.fromRawValue(rotation) ??
        InputImageRotation.rotation0deg;
  }

  // ── Simpan hasil ke backend ───────────────────────────────
  Future<void> saveDetection() async {
    if (detectedEmotion.value == 'Mendeteksi...' ||
        detectedEmotion.value == 'Arahkan wajah ke kamera...' ||
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
