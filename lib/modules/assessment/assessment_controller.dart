import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../services/api_service.dart';
import 'assessment_model.dart';

const _opts = ['Tidak Pernah', 'Jarang', 'Kadang-kadang', 'Sering', 'Selalu'];

// Data soal assessment
final _questions = [
  AssessmentQuestion(question: 'Seberapa sering kamu merasa cemas tanpa alasan yang jelas?',     options: _opts),
  AssessmentQuestion(question: 'Apakah kamu kesulitan untuk tidur atau istirahat dengan nyenyak?', options: _opts),
  AssessmentQuestion(question: 'Seberapa sering kamu merasa sedih atau kehilangan semangat?',      options: _opts),
  AssessmentQuestion(question: 'Apakah kamu merasa sulit berkonsentrasi pada pekerjaan/belajar?', options: _opts),
  AssessmentQuestion(question: 'Seberapa sering kamu merasa kelelahan meskipun sudah beristirahat?', options: _opts),
  AssessmentQuestion(question: 'Apakah kamu merasa kurang percaya diri akhir-akhir ini?',         options: _opts),
  AssessmentQuestion(question: 'Seberapa sering kamu merasa tidak bersemangat menjalani aktivitas?', options: _opts),
  AssessmentQuestion(question: 'Apakah kamu mengalami perubahan nafsu makan yang signifikan?',    options: _opts),
  AssessmentQuestion(question: 'Seberapa sering kamu merasa tertekan oleh tuntutan hidup?',       options: _opts),
  AssessmentQuestion(question: 'Apakah kamu merasa memiliki dukungan sosial yang cukup?',         options: _opts),
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
