import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/routes/app_routes.dart';
import '../../services/supabase_service.dart';

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
  bool _isLoading = false;

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

  Future<void> _register() async {
    final nama = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (nama.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
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
    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'Password minimal 6 karakter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SupabaseService.register(
        nama: nama,
        email: email,
        password: password,
      );
      // Langsung kirim OTP ke email yang baru terdaftar
      await SupabaseService.sendOtp(email);
      Get.snackbar(
        'Berhasil',
        'Registrasi berhasil! Cek email untuk kode OTP 6 digit.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE8F5E9),
        duration: const Duration(seconds: 4),
      );
      Get.offNamed(
        AppRoutes.otp,
        arguments: {'email': email, 'fromRegister': true},
      );
    } on AuthException catch (e) {
      Get.snackbar(
        'Gagal',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Tidak dapat terhubung. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header biru
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0052CC), Color(0xFF0052CC)],
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

                    _label('NAMA LENGKAP'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: nameController,
                      hint: 'Nama Anda',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),

                    _label('ALAMAT EMAIL'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: emailController,
                      hint: 'nama@gmail.com',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),

                    _label('KATA SANDI'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: passwordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: !_passwordVisible,
                      suffix: GestureDetector(
                        onTap: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        child: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _label('KONFIRMASI KATA SANDI'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: confirmPasswordController,
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: !_confirmPasswordVisible,
                      suffix: GestureDetector(
                        onTap: () => setState(
                          () => _confirmPasswordVisible =
                              !_confirmPasswordVisible,
                        ),
                        child: Icon(
                          _confirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

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
                        onPressed: _isLoading ? null : _register,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
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
                            onTap: () => Get.back(),
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

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.grey[700],
      letterSpacing: 0.5,
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) => TextField(
    controller: controller,
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0052CC), width: 2),
      ),
    ),
  );
}
