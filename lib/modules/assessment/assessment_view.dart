import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'assessment_controller.dart';

class AssessmentView extends GetView<AssessmentController> {
  const AssessmentView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: const Text('Tes Mental'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final progress =
                  (controller.selectedIndex.value + 1) /
                  controller.questions.length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tes Mental', style: theme.textTheme.headlineSmall),
                      Text(
                        '${controller.selectedIndex.value + 1}/${controller.questions.length}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  LinearProgressIndicator(
                    value: progress,
                    color: AppTheme.primaryBlue,
                    backgroundColor: Colors.grey.shade200,
                    minHeight: 8,
                  ),
                ],
              );
            }),
            const SizedBox(height: 28),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return PageView.builder(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.questions.length,
                    itemBuilder: (context, index) {
                      final question = controller.questions[index];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${index + 1}. ${question.question}',
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 18),
                                ...List.generate(question.options.length, (
                                  optionIndex,
                                ) {
                                  return Obx(() {
                                    final selected =
                                        controller.selectedAnswer.value ==
                                        optionIndex;
                                    return GestureDetector(
                                      onTap: () =>
                                          controller.chooseAnswer(optionIndex),
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 14,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppTheme.primaryBlue
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: selected
                                                ? AppTheme.primaryBlue
                                                : Colors.grey.shade300,
                                          ),
                                          boxShadow: [
                                            if (!selected)
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.03,
                                                ),
                                                blurRadius: 12,
                                                offset: const Offset(0, 8),
                                              ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: selected
                                                      ? Colors.white
                                                      : Colors.grey.shade400,
                                                  width: 2,
                                                ),
                                                color: selected
                                                    ? Colors.white
                                                    : Colors.transparent,
                                              ),
                                              child: selected
                                                  ? const Icon(
                                                      Icons.check,
                                                      size: 14,
                                                      color:
                                                          AppTheme.primaryBlue,
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                question.options[optionIndex],
                                                style: TextStyle(
                                                  color: selected
                                                      ? Colors.white
                                                      : AppTheme.textDark,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                                }),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryBlue,
                    size: 18,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Jawablah dengan jujur sesuai dengan perasaan Anda dalam 2 minggu terakhir.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.previousQuestion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: const BorderSide(color: AppTheme.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.selectedAnswer.value != null
                          ? controller.nextQuestion
                          : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Selanjutnya'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
