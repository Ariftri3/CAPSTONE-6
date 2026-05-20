import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 1400), () {
      Get.offNamed(AppRoutes.login);
    });
  }
}
