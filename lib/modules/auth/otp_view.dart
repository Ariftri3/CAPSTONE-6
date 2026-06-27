import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/routes/app_routes.dart';
import '../../services/supabase_service.dart';

/// OtpView — layar verifikasi OTP via email.
/// Alur:
///   1. User masukkan email → tap "Kirim Kode"
///   2. Supabase kirim email berisi 6 digit kode
///   3. User masukkan kode → tap "Verifikasi"
///   4. Kalau valid → masuk ke dashboard
class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final emailController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _codeSent = false;
  bool _isLoading = false;
  bool _fromRegister = false;

  @override
  void initState() {
    super.initState();

    final dynamic args = Get.arguments;
    if (args is Map) {
      final email = args['email']?.toString();
      if (email != null && email.isNotEmpty) {
        emailController.text = email;
      }
      _fromRegister = args['fromRegister'] == true;
    }

    if (_fromRegister && emailController.text.trim().isNotEmpty) {
      _codeSent = true;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    for (final c in otpControllers) c.dispose();
    for (final f in otpFocusNodes) f.dispose();
    super.dispose();
  }

  // ── Step 1: Kirim OTP ──────────────────────────────────────
  Future<void> _sendOtp() async {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Masukkan email terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await SupabaseService.sendOtp(emailController.text.trim());
      setState(() => _codeSent = true);
      Get.snackbar(
        'Kode Terkirim',
        'Cek inbox email ${emailController.text.trim()} untuk kode OTP 6 digit.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE8F5E9),
        duration: const Duration(seconds: 4),
      );
      // Auto-focus ke kotak OTP pertama
      otpFocusNodes[0].requestFocus();
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
        'Gagal mengirim kode. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Step 2: Verifikasi kode OTP ────────────────────────────
  Future<void> _verifyOtp() async {
    final token = otpControllers.map((c) => c.text).join();
    if (token.length < 6) {
      Get.snackbar(
        'Error',
        'Masukkan 6 digit kode OTP',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await SupabaseService.verifyOtp(
        email: emailController.text.trim(),
        token: token,
      );

      if (_fromRegister) {
        Get.offAllNamed(AppRoutes.login);
        Get.snackbar(
          'Berhasil',
          'Email berhasil diverifikasi. Silakan login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE8F5E9),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.offNamed(AppRoutes.dashboard);
      }
    } on AuthException catch (e) {
      Get.snackbar(
        'Kode Salah',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
      );
      // Reset kotak OTP
      for (final c in otpControllers) c.clear();
      otpFocusNodes[0].requestFocus();
    } catch (_) {
      Get.snackbar(
        'Error',
        'Verifikasi gagal. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFFEBEE),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Build kotak OTP ────────────────────────────────────────
  Widget _otpBox(int index) {
    return SizedBox(
      width: 36,
      height: 52,
      child: TextField(
        controller: otpControllers[index],
        focusNode: otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: false,
        enableSuggestions: false,
        autocorrect: false,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0052CC), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            otpFocusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
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
                    const SizedBox(height: 16),
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sms_outlined,
                          color: Color(0xFF0052CC),
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        _codeSent
                            ? 'Masukkan Kode OTP'
                            : (_fromRegister
                                  ? 'Verifikasi akun'
                                  : 'Login dengan OTP'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _codeSent
                            ? 'Kode 8 digit telah dikirim ke\n${emailController.text.trim()}'
                            : 'Masukkan email kamu, kami akan kirim kode verifikasi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Input email (tampil hanya sebelum kode dikirim)
                    if (!_codeSent) ...[
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
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'nama@gmail.com',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(height: 24),
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
                          onPressed: _isLoading ? null : _sendOtp,
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
                                  'Kirim Kode OTP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    // Input 6 kotak OTP + tombol verifikasi
                    if (_codeSent) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (i) => _otpBox(i)),
                      ),
                      const SizedBox(height: 32),
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
                          onPressed: _isLoading ? null : _verifyOtp,
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
                                  'Verifikasi & Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _sendOtp,
                          child: const Text(
                            'Kirim ulang kode',
                            style: TextStyle(
                              color: Color(0xFF0052CC),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
