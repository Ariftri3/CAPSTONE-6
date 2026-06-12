import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../services/api_service.dart';
import '../../services/google_auth_service.dart';
import '../../services/storage_service.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool _passwordVisible = false;
  bool _isLoading       = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header dengan background biru
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0052CC), Color(0xFF0052CC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MindCare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Login',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Masukkan akun Anda dengan benar dan Anda',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Email Field
                    Text(
                      'ALAMAT EMAIL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'nama@gmail.com',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0052CC),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Password Field
                    Text(
                      'KATA SANDI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.grey,
                        ),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          child: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF0052CC),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {},
                        child: const Text(
                          'Lupa password?',
                          style: TextStyle(
                            color: Color(0xFF0052CC),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0052CC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : () async {
                          if (emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Email dan password wajib diisi',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            final result = await ApiService.login(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );

                            if (result['success'] == true) {
                              // ✅ Simpan token & data user ke storage
                              final user = result['user'];
                              await StorageService.saveSession(
                                token:  result['token'],
                                userId: user['id'],
                                nama:   user['nama'],
                                email:  user['email'],
                              );
                              Get.offNamed(AppRoutes.dashboard);
                            } else {
                              Get.snackbar(
                                'Gagal',
                                result['message'] ?? 'Login gagal',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFFFEBEE),
                              );
                            }
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Tidak dapat terhubung ke server. Pastikan backend berjalan.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFFFEBEE),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Atau Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: Colors.grey[300]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Atau',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(height: 1, color: Colors.grey[300]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Google Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : () async {
                          setState(() => _isLoading = true);
                          try {
                            final userCredential =
                                await GoogleAuthService.signInWithGoogle();

                            if (userCredential != null && userCredential.user != null) {
                              final gUser = userCredential.user!;
                              
                              // Sinkronisasi ke backend Flask & dapatkan JWT
                              final result = await ApiService.loginWithGoogle(
                                nama: gUser.displayName ?? 'Google User',
                                email: gUser.email ?? '',
                                fotoUrl: gUser.photoURL ?? '',
                              );

                              if (result['success'] == true) {
                                final dbUser = result['user'];
                                await StorageService.saveSession(
                                  token:  result['token'],
                                  userId: dbUser['id'],
                                  nama:   dbUser['nama'],
                                  email:  dbUser['email'],
                                );

                                Get.snackbar(
                                  "Berhasil",
                                  "Login Google berhasil",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFE8F5E9),
                                );

                                Get.offNamed(AppRoutes.dashboard);
                              } else {
                                Get.snackbar(
                                  "Gagal",
                                  result['message'] ?? "Gagal sinkronisasi data ke backend",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFFFFEBEE),
                                );
                              }
                            } else {
                              Get.snackbar(
                                "Gagal",
                                "Login Google dibatalkan",
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFFFEBEE),
                              );
                            }
                          } catch (e) {
                            print(e);
                            Get.snackbar(
                              "Error",
                              "Gagal terhubung ke server backend atau Firebase.",
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFFFEBEE),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        icon: const Icon(Icons.login, color: Colors.black87),
                        label: const Text(
                          'Login dengan Google',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Register Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(AppRoutes.register);
                            },
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Color(0xFF0052CC),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
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
}
