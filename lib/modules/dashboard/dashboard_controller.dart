import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';

class DashboardController extends GetxController {
  final moodIndex    = 0.obs;
  final isLoading    = false.obs;
  final userName     = ''.obs;
  final moodChartData = <FlSpot>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserName();
    loadMoodData();
  }

  /// Ambil nama user dari storage lokal
  Future<void> loadUserName() async {
    final user = await StorageService.getUser();
    userName.value = user['nama'] ?? 'Pengguna';
  }

  /// Ambil data mood 7 hari dari backend
  Future<void> loadMoodData() async {
    isLoading.value = true;
    try {
      final result = await ApiService.getMoods(limit: 7);
      if (result['success'] == true) {
        final List data = result['data'];
        // Ubah data dari API menjadi FlSpot untuk grafik
        final spots = data.reversed.toList().asMap().entries.map((e) {
          return FlSpot(e.key.toDouble(), (e.value['mood_value'] as num).toDouble());
        }).toList();

        moodChartData.value = spots.isEmpty
            ? _defaultData() // fallback jika belum ada data
            : spots;
      }
    } catch (e) {
      moodChartData.value = _defaultData();
    } finally {
      isLoading.value = false;
    }
  }

  /// Simpan mood yang dipilih user ke backend
  Future<void> selectMood(int index) async {
    moodIndex.value = index;
    try {
      await ApiService.saveMood(index + 1); // 0-based index → 1-5 value
      await loadMoodData(); // refresh chart
    } catch (e) {
      // Gagal simpan, tapi UI tetap update
    }
  }

  List<FlSpot> _defaultData() => [
    const FlSpot(0, 3.0),
    const FlSpot(1, 3.5),
    const FlSpot(2, 3.0),
    const FlSpot(3, 4.0),
    const FlSpot(4, 3.5),
    const FlSpot(5, 4.0),
    const FlSpot(6, 4.5),
  ];
}
