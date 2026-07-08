import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';

class AssessmentResultView extends StatelessWidget {
  const AssessmentResultView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final score = args != null && args['score'] != null
        ? args['score'] as int
        : 0;

    final percent = (score.clamp(0, 100) / 100).toDouble();
    final status = score >= 75
      ? 'Mood Positif'
      : score >= 50
        ? 'Mood Stabil'
        : 'Perlu Perhatian';
    final statusColor = score >= 75
        ? const Color(0xFFEC6A37)
        : score >= 50
        ? const Color(0xFFF2A842)
        : AppTheme.primaryBlue;
    final statusEmoji = score >= 75
        ? '😟'
        : score >= 50
        ? '😐'
        : '😊';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Get.back(),
        ),
        title: const Text('Hasil Tes'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      backgroundColor: AppTheme.primaryLight,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Hasil Mood Hari Ini',
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 188,
                          height: 188,
                          child: CircularProgressIndicator(
                            value: percent,
                            strokeWidth: 16,
                            color: statusColor,
                            backgroundColor: AppTheme.primaryLight,
                          ),
                        ),
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                statusEmoji,
                                style: const TextStyle(fontSize: 42),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Hasil assessment menunjukkan kondisi mood Anda hari ini. Terus pantau perkembangan mood setiap hari dan manfaatkan fitur jurnal untuk mencatat pengalaman atau perasaan yang Anda alami.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Saran untukmu',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 12),
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _suggestionTile('Istirahat yang cukup'),
                _suggestionTile('Olahraga ringan'),
                _suggestionTile('Kelola stres'),
                _suggestionTile('Curhat'),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.headset_mic, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ingin bicara dengan ahli?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Psikolog kami siap membantu kapan saja.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.dashboard);
              },
              child: const Text('Selesai'),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _suggestionTile(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: AppTheme.primaryBlue),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
