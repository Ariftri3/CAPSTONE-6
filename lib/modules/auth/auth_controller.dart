import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/routes/app_routes.dart';

class AuthController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _listenToAuthState();
  }

  void _listenToAuthState() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        // Cek route saat ini agar tidak double navigate jika sudah di dashboard
        if (Get.currentRoute != AppRoutes.dashboard) {
          Get.offAllNamed(AppRoutes.dashboard);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        if (Get.currentRoute != AppRoutes.login) {
          Get.offAllNamed(AppRoutes.login);
        }
      }
    });
  }
}
