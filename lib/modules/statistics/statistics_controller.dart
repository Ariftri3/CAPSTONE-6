import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsController extends GetxController {
  final weeklyMoodData = <FlSpot>[
    const FlSpot(0, 3.5),
    const FlSpot(1, 3.9),
    const FlSpot(2, 4.1),
    const FlSpot(3, 4.3),
    const FlSpot(4, 4.2),
    const FlSpot(5, 4.4),
    const FlSpot(6, 4.7),
  ].obs;

  final insights = <String>[
    'Performa mood Anda meningkatkan 14% minggu ini.',
    'Tidur lebih nyenyak membantu stabilkan emosi.',
    'Chat AI merekomendasikan relaksasi visual setiap hari.',
  ].obs;
}
