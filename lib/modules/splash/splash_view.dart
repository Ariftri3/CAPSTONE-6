import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class SplashView extends GetView {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF2A2A3E)),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 15,
                            child: Container(
                              width: 50,
                              height: 65,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0052CC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CustomPaint(painter: HeadPainter()),
                            ),
                          ),
                          Positioned(
                            right: 15,
                            child: Container(
                              width: 50,
                              height: 65,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0052CC),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: CustomPaint(painter: HeadPainter()),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _dot(8),
                                  const SizedBox(width: 6),
                                  _dot(8),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _dot(6),
                                  const SizedBox(width: 4),
                                  _dot(6),
                                  const SizedBox(width: 4),
                                  _dot(6),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'MindCare',
                      style:
                          Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'jaga kesehatan mental Anda dengan mudah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          // Cek sesi Supabase — kalau masih login, langsung ke dashboard
                          final session =
                              Supabase.instance.client.auth.currentSession;
                          if (session != null) {
                            Get.offNamed(AppRoutes.dashboard);
                          } else {
                            Get.toNamed(AppRoutes.login);
                          }
                        },
                        child: const Text('Mulai',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        final session =
                            Supabase.instance.client.auth.currentSession;
                        if (session != null) {
                          Get.offNamed(AppRoutes.dashboard);
                        } else {
                          Get.toNamed(AppRoutes.login);
                        }
                      },
                      child: const Text('Sudah punya akun? Login',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(double size) => Container(
        width: size,
        height: size,
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      );
}

class HeadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0052CC)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.3), 12, paint);
  }

  @override
  bool shouldRepaint(HeadPainter oldDelegate) => false;
}
