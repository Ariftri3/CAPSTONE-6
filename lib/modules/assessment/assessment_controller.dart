import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../services/api_service.dart';
import 'assessment_model.dart';

const _opts = ['Tidak Pernah', 'Jarang', 'Kadang-kadang', 'Sering', 'Selalu'];

// Data soal assessment
final _questions = [
  AssessmentQuestion(question: 'Hari ini saya merasa sulit merasa tenang ketika menghadapi aktivitas sehari-hari.',  options: _opts,),
  AssessmentQuestion(question: 'Hari ini saya merasa cemas atau khawatir tanpa alasan yang jelas.',  options: _opts,),
  AssessmentQuestion(question: 'Hari ini saya merasa sedih atau murung sehingga memengaruhi suasana hati saya.',  options: _opts,),
  AssessmentQuestion(question: 'Hari ini saya merasa sulit berkonsentrasi saat belajar, bekerja, atau melakukan aktivitas lainnya.',  options: _opts,),
  AssessmentQuestion(question: 'Hari ini saya merasa mudah lelah meskipun aktivitas yang saya lakukan tidak terlalu berat.',  options: _opts,),
  AssessmentQuestion(question: 'Hari ini saya merasa mudah tersinggung atau marah terhadap hal-hal kecil.',  options: _opts,),
  AssessmentQuestion(question: 'Hari ini saya merasa terbebani oleh masalah yang sedang saya hadapi.',  options: _opts,),
  AssessmentQuestion(question: 'Hari ini saya merasa kesulitan menikmati aktivitas yang biasanya saya sukai.',  options: _opts,),
  AssessmentQuestion(question: 'Hari ini saya merasa memiliki dukungan dari keluarga atau orang terdekat ketika menghadapi masalah.',  options: _opts,),
  AssessmentQuestion(question: 'Secara keseluruhan, hari ini saya merasa kondisi emosional saya berada dalam keadaan yang baik.',  options: _opts,),
];

class AssessmentController extends GetxController {
  final questions      = <AssessmentQuestion>[].obs;
  final selectedIndex  = 0.obs;
  final selectedAnswer = RxnInt();
  final answers        = <int?>[].obs;
  final isSaving       = false.obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    questions.addAll(_questions);
    answers.addAll(List<int?>.filled(questions.length, null));
    pageController = PageController(initialPage: 0);
    selectedAnswer.value = answers[0];
  }

  void nextQuestion() {
    if (selectedAnswer.value == null) return;
    answers[selectedIndex.value] = selectedAnswer.value;

    if (selectedIndex.value < questions.length - 1) {
      selectedIndex.value++;
      pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      selectedAnswer.value = answers[selectedIndex.value];
    } else {
      _submitAssessment();
    }
  }

  void previousQuestion() {
    if (selectedIndex.value > 0) {
      selectedIndex.value--;
      pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeInOut,
      );
      selectedAnswer.value = answers[selectedIndex.value];
    }
  }

  void chooseAnswer(int index) {
    selectedAnswer.value = index;
  }

  int calculateScore() {
    final filled = answers.whereType<int>().toList();
    if (filled.isEmpty) return 0;
    final total = filled.fold<int>(0, (sum, v) => sum + (v + 1));
    return ((total / (filled.length * 4)) * 100).round();
  }

  /// Simpan hasil ke backend lalu pindah ke halaman hasil
  Future<void> _submitAssessment() async {
    final score = calculateScore();
    isSaving.value = true;
    try {
      await ApiService.saveAssessment(score);
    } catch (_) {
      // Tetap lanjut ke halaman hasil meski gagal simpan
    } finally {
      isSaving.value = false;
    }
    Get.toNamed(AppRoutes.assessmentResult, arguments: {'score': score});
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
