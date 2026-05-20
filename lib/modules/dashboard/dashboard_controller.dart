import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final moodIndex = 0.obs;
  final moodChartData = <FlSpot>[
    const FlSpot(0, 4),
    const FlSpot(1, 3.8),
    const FlSpot(2, 4.3),
    const FlSpot(3, 4.1),
    const FlSpot(4, 4.6),
    const FlSpot(5, 4.8),
    const FlSpot(6, 5),
  ].obs;

  void selectMood(int index) {
    moodIndex.value = index;
  }
}
