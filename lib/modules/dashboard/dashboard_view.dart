import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../services/supabase_service.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => Get.toNamed(AppRoutes.profile),
              tooltip: 'Profil',
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await SupabaseService.logout();
                Get.offAllNamed(AppRoutes.login);
              },
              tooltip: 'Logout',
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.primaryLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo, Teman!', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Tingkatkan kesehatan mentalmu dengan ringkasan harian dan rekomendasi terbaik.',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih Mood',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bagikan suasana hati harianmu agar kamu bisa mendapatkan rekomendasi yang lebih tepat.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final selected = controller.moodIndex.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _moodOption(
                          '😀',
                          'Bahagia',
                          selected == 0,
                          () => controller.selectMood(0),
                        ),
                        const SizedBox(width: 10),
                        _moodOption(
                          '😐',
                          'Biasa',
                          selected == 1,
                          () => controller.selectMood(1),
                        ),
                        const SizedBox(width: 10),
                        _moodOption(
                          '😔',
                          'Sedih',
                          selected == 2,
                          () => controller.selectMood(2),
                        ),
                        const SizedBox(width: 10),
                        _moodOption(
                          '😣',
                          'Stres',
                          selected == 3,
                          () => controller.selectMood(3),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 22),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ringkasan Hari Ini',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text('12 Okt', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _statusChip('Biasa'),
                            const SizedBox(width: 8),
                            _statusChip('Sedih'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hari ini kamu merasa sedikit lelah namun tetap berusaha menjalani hari dengan penuh tekad.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: [
                _buildMenuCard(
                  context,
                  'Tes Mental',
                  Icons.quiz,
                  AppRoutes.assessment,
                ),
                _buildMenuCard(
                  context,
                  'Jurnal Harian',
                  Icons.book,
                  AppRoutes.journal,
                ),
                _buildMenuCard(
                  context,
                  'Chat dengan AI',
                  Icons.chat_bubble,
                  AppRoutes.chatbot,
                ),
                _buildMenuCard(
                  context,
                  'Lihat Statistik',
                  Icons.show_chart,
                  AppRoutes.statistics,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mood 7 Hari Terakhir',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  const labels = [
                                    'Sen',
                                    'Sel',
                                    'Rab',
                                    'Kam',
                                    'Jum',
                                    'Sab',
                                    'Min',
                                  ];
                                  return Text(
                                    labels[value.toInt().clamp(
                                      0,
                                      labels.length - 1,
                                    )],
                                    style: const TextStyle(fontSize: 12),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: controller.moodChartData,
                              isCurved: true,
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.primaryBlue,
                                  AppTheme.accentBlue,
                                ],
                              ),
                              barWidth: 4,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryBlue.withOpacity(0.25),
                                    AppTheme.primaryLight.withOpacity(0.1),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          minY: 2.5,
                          maxY: 5.5,
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    String route,
  ) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue),
            ),
            const Spacer(),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _moodOption(
    String emoji,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryBlue : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
