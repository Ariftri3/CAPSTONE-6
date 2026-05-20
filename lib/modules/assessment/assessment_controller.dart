import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../data/providers/assessment_provider.dart';
import 'assessment_model.dart';

class AssessmentController extends GetxController {
  final provider = Get.find<AssessmentProvider>();
  final questions = <AssessmentQuestion>[].obs;
  final selectedIndex = 0.obs;
  final selectedAnswer = RxnInt();
  final answers = <int?>[].obs;
  late final PageController pageController;

  @override
  void onInit() {
    super.onInit();
    questions.addAll(provider.fetchQuestions());
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
      Get.toNamed(
        AppRoutes.assessmentResult,
        arguments: {'score': calculateScore()},
      );
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
    final filledAnswers = answers.whereType<int>().toList();
    if (filledAnswers.isEmpty) return 0;
    final total = filledAnswers.fold<int>(0, (sum, value) => sum + (value + 1));
    return ((total / (filledAnswers.length * 4)) * 100).round();
  }
}
