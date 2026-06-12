import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/routes/app_routes.dart';
import '../../services/api_service.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

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
                        'Daftar',
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
                        'Buat akun baru untuk memulai',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Name Field
                    Text(
                      'NAMA LENGKAP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Nama Anda',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(
                          Icons.person_outline,
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
                    const SizedBox(height: 20),
                    // Confirm Password Field
                    Text(
                      'KONFIRMASI KATA SANDI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
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
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                            });
                          },
                          child: Icon(
                            _confirmPasswordVisible
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
                    const SizedBox(height: 28),
                    // Register Button
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
                          final nama = nameController.text.trim();
                          final email = emailController.text.trim();
                          final password = passwordController.text.trim();
                          final confirmPassword = confirmPasswordController.text.trim();

                          if (nama.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Semua kolom wajib diisi',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFFFEBEE),
                            );
                            return;
                          }

                          if (password != confirmPassword) {
                            Get.snackbar(
                              'Error',
                              'Konfirmasi password tidak cocok',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFFFEBEE),
                            );
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            final result = await ApiService.register(nama, email, password);

                            if (result['success'] == true) {
                              Get.snackbar(
                                'Berhasil',
                                'Registrasi berhasil! Silakan login.',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFE8F5E9),
                              );
                              // Kembali ke halaman Login
                              Get.offNamed(AppRoutes.login);
                            } else {
                              Get.snackbar(
                                'Gagal',
                                result['message'] ?? 'Registrasi gagal',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: const Color(0xFFFFEBEE),
                              );
                            }
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Tidak dapat terhubung ke server backend.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFFFEBEE),
                            );
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        child: _isLoading 
                          ? const SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: const Text(
                              'Login',
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
