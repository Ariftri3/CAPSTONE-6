import 'dart:convert';
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

/// ApiService — komunikasi dengan backend Flask.
/// Perubahan dari versi lama:
///   * Token diambil dari Supabase (bukan SharedPreferences lagi)
///   * Method login(), register(), loginWithGoogle() DIHAPUS
///     (sekarang ditangani SupabaseService langsung)
///   * Ditambah saveEmotion() dan getEmotions() untuk fitur deteksi emosi
///   * baseUrl sekarang otomatis menyesuaikan platform (web/emulator/device)
class ApiService {
  // ⚠️  Isi dengan URL ngrok yang aktif sekarang, contoh:
  // "https://a1b2-34-56-78-90.ngrok-free.app"
  // Setiap kali ngrok di-restart (tier gratis), URL-nya berubah — jadi
  // update lagi nilai ini setiap kali itu terjadi.
  static const String _ngrokUrl = "https://xxxx-xx-xx-xx-xx.ngrok-free.app";

  static String get baseUrl => _ngrokUrl;

  // ── Header dengan Supabase access token ──────────────────────
  static Map<String, String> get _authHeaders {
    final token = SupabaseService.accessToken;

    print("================================");
    print("ACCESS TOKEN:");
    print(token);
    print("================================");

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static const _headers = {'Content-Type': 'application/json'};

  // ════════════════════════════════════════════════
  // MOOD
  // ════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getMoods({int limit = 7}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood?limit=$limit'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> saveMood(
    int moodValue, {
    String catatan = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mood'),
      headers: _authHeaders,
      body: jsonEncode({'mood_value': moodValue, 'catatan': catatan}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateMood(
    int moodId, {
    required int moodValue,
    String catatan = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/mood/$moodId'),
      headers: _authHeaders,
      body: jsonEncode({'mood_value': moodValue, 'catatan': catatan}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteMood(int moodId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/mood/$moodId'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // JOURNAL
  // ════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getJournals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/journal'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createJournal({
    required String title,
    required String content,
    String mood = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/journal'),
      headers: _authHeaders,
      body: jsonEncode({'title': title, 'content': content, 'mood': mood}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateJournal(
    int id, {
    required String title,
    required String content,
    String mood = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/journal/$id'),
      headers: _authHeaders,
      body: jsonEncode({'title': title, 'content': content, 'mood': mood}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteJournal(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/journal/$id'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // ASSESSMENT
  // ════════════════════════════════════════════════

  static Future<Map<String, dynamic>> saveAssessment(int score) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assessment'),
      headers: _authHeaders,
      body: jsonEncode({'score': score}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getAssessments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/assessment'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // CHATBOT
  // ════════════════════════════════════════════════

  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot'),
      headers: _authHeaders,
      body: jsonEncode({'message': message}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getChatHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chatbot/history'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // PROFILE
  // ════════════════════════════════════════════════

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String nama,
    String fotoUrl = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: _authHeaders,
      body: jsonEncode({'nama': nama, 'foto_url': fotoUrl}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProfileStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/stats'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/profile'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // EMOTION DETECTION (BARU)
  // ════════════════════════════════════════════════

  /// POST /emotion — simpan hasil deteksi emosi wajah
  static Future<Map<String, dynamic>> saveEmotion({
    required String emotionLabel,
    required double confidence,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/emotion'),
      headers: _authHeaders,
      body: jsonEncode({
        'emotion_label': emotionLabel,
        'confidence': confidence,
      }),
    );
    return jsonDecode(response.body);
  }

  /// GET /emotion?limit=20 — ambil riwayat deteksi emosi
  static Future<Map<String, dynamic>> getEmotions({int limit = 20}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/emotion?limit=$limit'),
      headers: _authHeaders,
    );
    return jsonDecode(response.body);
  }
}
