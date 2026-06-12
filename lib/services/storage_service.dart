import 'package:shared_preferences/shared_preferences.dart';

/// StorageService — menyimpan data lokal (JWT token, info user)
/// Dipanggil setelah login berhasil, dan dibaca di setiap request API.
class StorageService {
  static const _keyToken   = 'auth_token';
  static const _keyUserId  = 'user_id';
  static const _keyNama    = 'user_nama';
  static const _keyEmail   = 'user_email';

  // ── Simpan token + data user setelah login ──────────────────
  static Future<void> saveSession({
    required String token,
    required int    userId,
    required String nama,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken,  token);
    await prefs.setInt   (_keyUserId, userId);
    await prefs.setString(_keyNama,   nama);
    await prefs.setString(_keyEmail,  email);
  }

  // ── Ambil token (untuk dikirim ke API) ──────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ── Ambil data user ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id':    prefs.getInt(_keyUserId)    ?? 0,
      'nama':  prefs.getString(_keyNama)   ?? '',
      'email': prefs.getString(_keyEmail)  ?? '',
    };
  }

  // ── Cek apakah sudah login ───────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Hapus sesi (logout) ──────────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
