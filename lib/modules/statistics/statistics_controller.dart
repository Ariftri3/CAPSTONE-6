import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';

class StatisticsController extends GetxController {
  final isLoading      = false.obs;
  final weeklyMoodData = <FlSpot>[].obs;
  final insights       = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    isLoading.value = true;
    try {
      final result = await ApiService.getMoods(limit: 7);
      if (result['success'] == true) {
        final List data = result['data'];

        if (data.isNotEmpty) {
          // Ubah data API menjadi FlSpot untuk grafik
          final spots = data.reversed.toList().asMap().entries.map((e) {
            return FlSpot(
              e.key.toDouble(),
              (e.value['mood_value'] as num).toDouble(),
            );
          }).toList();
          weeklyMoodData.value = spots;

          // Hitung insight otomatis dari data
          _generateInsights(data);
        } else {
          _loadDefaultData();
        }
      } else {
        _loadDefaultData();
      }
    } catch (e) {
      _loadDefaultData();
    } finally {
      isLoading.value = false;
    }
  }

  void _generateInsights(List data) {
    final values = data
        .map((e) => (e['mood_value'] as num).toDouble())
        .toList();

    final avg = values.reduce((a, b) => a + b) / values.length;
    final latest = values.first;
    final oldest = values.last;
    final diff   = latest - oldest;

    final List<String> result = [];

    if (diff > 0) {
      result.add('Mood kamu meningkat ${(diff * 20).round()}% dibanding awal minggu 🎉');
    } else if (diff < 0) {
      result.add('Mood kamu sedikit menurun minggu ini. Tetap semangat ya 💪');
    } else {
      result.add('Mood kamu stabil minggu ini. Pertahankan! 😊');
    }

    if (avg >= 4.0) {
      result.add('Rata-rata mood minggu ini: Baik (${avg.toStringAsFixed(1)}/5)');
    } else if (avg >= 3.0) {
      result.add('Rata-rata mood minggu ini: Cukup (${avg.toStringAsFixed(1)}/5)');
    } else {
      result.add('Coba luangkan waktu untuk relaksasi dan istirahat cukup.');
    }

    result.add('Konsistensi mencatat mood membantu kamu memahami diri sendiri lebih baik.');
    insights.value = result;
  }

  void _loadDefaultData() {
    weeklyMoodData.value = [
      const FlSpot(0, 3.5),
      const FlSpot(1, 3.9),
      const FlSpot(2, 4.1),
      const FlSpot(3, 4.3),
      const FlSpot(4, 4.2),
      const FlSpot(5, 4.4),
      const FlSpot(6, 4.7),
    ];
    insights.value = [
      'Belum ada data mood minggu ini. Coba catat mood harianmu!',
      'Konsistensi mencatat mood membantu melacak kesehatan mentalmu.',
    ];
  }
}
