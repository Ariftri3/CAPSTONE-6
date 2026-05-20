import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';
import '../../modules/assessment/assessment_view.dart';
import '../../modules/chatbot/chatbot_view.dart';
import '../../modules/dashboard/dashboard_view.dart';
import '../../modules/detection/emotion_detection_view.dart';
import '../../modules/statistics/statistics_view.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}

class MainShellView extends StatelessWidget {
  MainShellView({super.key});

  final controller = Get.put(NavigationController());

  final pages = [
    const DashboardView(),
    const StatisticsView(),
    const EmotionDetectionView(),
    const ChatbotView(),
    const AssessmentView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: pages[controller.currentIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'Statistik',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.face), label: 'Deteksi'),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Tes'),
          ],
        ),
      ),
    );
  }
}
