import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/bindings/app_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Init Supabase (menggantikan Firebase.initializeApp) ──────
  // Ganti nilai ini dengan Project URL dan Anon Key dari Supabase Dashboard
  await Supabase.initialize(
    url: 'https://eqhlekptvbcvznsmnorv.supabase.co',
    anonKey: 'sb_publishable_AGZyN7KYNWJxL_oCvhuhuA_KVtGJTj0', // ← ganti dengan anon key asli dari Supabase Dashboard
  );

  runApp(const MindCareApp());
}

class MindCareApp extends StatelessWidget {
  const MindCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MindCare',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      unknownRoute: GetPage(
        name: '/notfound',
        page: () => const Scaffold(
          body: Center(child: Text('Terjadi kesalahan URL. Silakan kembali.')),
        ),
      ),
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
    );
  }
}
