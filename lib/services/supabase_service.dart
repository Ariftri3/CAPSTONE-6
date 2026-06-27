import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// SupabaseService — satu-satunya pintu untuk semua operasi Auth Supabase.
/// Menggantikan GoogleAuthService (Firebase) dan bagian login/register
/// di ApiService yang lama.
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ────────────────────────────────────────────────
  // Ambil access token yang sedang aktif
  // Dipakai oleh ApiService._authHeaders()
  // ────────────────────────────────────────────────
  static String? get accessToken => _client.auth.currentSession?.accessToken;

  // ────────────────────────────────────────────────
  // Ambil user yang sedang login (null kalau belum login)
  // ────────────────────────────────────────────────
  static User? get currentUser => _client.auth.currentUser;

  // ────────────────────────────────────────────────
  // Email + Password: Register
  // ────────────────────────────────────────────────
  /// Daftar akun baru dengan email + password.
  /// [nama] disimpan di user_metadata → trigger DB otomatis buat baris profiles.
  static Future<AuthResponse> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': nama},
    );
  }

  // ────────────────────────────────────────────────
  // Email + Password: Login
  // ────────────────────────────────────────────────
  static Future<AuthResponse> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ────────────────────────────────────────────────
  // OTP: Kirim kode 8 digit ke email
  // ────────────────────────────────────────────────
  static Future<void> sendOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true, // buat akun otomatis kalau belum ada
    );
  }

  // ────────────────────────────────────────────────
  // OTP: Verifikasi kode yang dimasukkan user
  // ────────────────────────────────────────────────
  static Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  // ────────────────────────────────────────────────
  // Google Sign-In lewat Supabase
  // (Supabase membuka Google OAuth di browser/webview)
  // ────────────────────────────────────────────────
  static Future<void> loginWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.mindcare://login-callback',
    );
  }

  // ────────────────────────────────────────────────
  // Logout
  // ────────────────────────────────────────────────
  static Future<void> logout() async {
    await _client.auth.signOut();
  }
}
