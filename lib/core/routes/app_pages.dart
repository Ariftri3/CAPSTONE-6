import 'package:get/get.dart';
import '../../modules/assessment/assessment_binding.dart';
import '../../modules/assessment/assessment_result_view.dart';
import '../../modules/assessment/assessment_view.dart';
import '../../modules/auth/login_view.dart';
import '../../modules/auth/register_view.dart';
import '../../modules/auth/otp_view.dart';          // ← BARU
import '../../modules/journal/journal_view.dart';
import '../../modules/help/help_view.dart';
import '../../modules/profile/profile_view.dart';
import '../../modules/profile/profile_binding.dart';
import '../../modules/chatbot/chatbot_binding.dart';
import '../../modules/chatbot/chatbot_view.dart';
import '../../modules/dashboard/dashboard_binding.dart';
import '../../modules/detection/emotion_detection_binding.dart';
import '../../modules/detection/emotion_detection_view.dart';
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/splash_view.dart';
import '../../modules/statistics/statistics_binding.dart';
import '../../modules/statistics/statistics_view.dart';
import '../views/main_shell_view.dart';
import 'app_routes.dart';

abstract class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(name: AppRoutes.login, page: () => const LoginView()),
    GetPage(name: AppRoutes.register, page: () => const RegisterView()),
    GetPage(name: AppRoutes.otp, page: () => const OtpView()),   // ← BARU
    GetPage(
      name: AppRoutes.dashboard,
      page: () => MainShellView(),
      bindings: [
        DashboardBinding(),
        StatisticsBinding(),
        EmotionDetectionBinding(),
        ChatbotBinding(),
        AssessmentBinding(),
      ],
    ),
    GetPage(
      name: AppRoutes.statistics,
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
    ),
    GetPage(
      name: AppRoutes.detection,
      page: () => const EmotionDetectionView(),
      binding: EmotionDetectionBinding(),
    ),
    GetPage(
      name: AppRoutes.chatbot,
      page: () => const ChatbotView(),
      binding: ChatbotBinding(),
    ),
    GetPage(
      name: AppRoutes.assessment,
      page: () => const AssessmentView(),
      binding: AssessmentBinding(),
    ),
    GetPage(
      name: AppRoutes.assessmentResult,
      page: () => const AssessmentResultView(),
    ),
    GetPage(name: AppRoutes.journal, page: () => const JournalView()),
    GetPage(name: AppRoutes.help, page: () => const HelpView()),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
  ];
}
