import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

/// ApiService — semua komunikasi dengan backend Flask
/// Base URL: ganti sesuai IP komputer yang menjalankan Flask
class ApiService {
  static const String baseUrl = "http://localhost:5000";

  // ── Header dengan JWT token (untuk endpoint yang dilindungi) ─
  static Future<Map<String, String>> _authHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Content-Type':  'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static const _headers = {'Content-Type': 'application/json'};

  // ════════════════════════════════════════════════
  // AUTH
  // ════════════════════════════════════════════════

  /// POST /login
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  /// POST /login/google
  static Future<Map<String, dynamic>> loginWithGoogle({
    required String nama,
    required String email,
    required String fotoUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login/google'),
      headers: _headers,
      body: jsonEncode({
        'nama': nama,
        'email': email,
        'foto_url': fotoUrl,
      }),
    );
    return jsonDecode(response.body);
  }

  /// POST /register
  static Future<Map<String, dynamic>> register(
    String nama,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers,
      body: jsonEncode({'nama': nama, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // MOOD
  // ════════════════════════════════════════════════

  /// GET /mood?limit=7 — ambil riwayat mood
  static Future<Map<String, dynamic>> getMoods({int limit = 7}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/mood?limit=$limit'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }

  /// POST /mood — simpan mood hari ini
  static Future<Map<String, dynamic>> saveMood(
    int moodValue, {
    String catatan = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/mood'),
      headers: await _authHeaders(),
      body: jsonEncode({'mood_value': moodValue, 'catatan': catatan}),
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // JOURNAL
  // ════════════════════════════════════════════════

  /// GET /journal — ambil semua jurnal
  static Future<Map<String, dynamic>> getJournals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/journal'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }

  /// POST /journal — buat jurnal baru
  static Future<Map<String, dynamic>> createJournal({
    required String title,
    required String content,
    String mood = '',
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/journal'),
      headers: await _authHeaders(),
      body: jsonEncode({'title': title, 'content': content, 'mood': mood}),
    );
    return jsonDecode(response.body);
  }

  /// PUT /journal/<id> — edit jurnal
  static Future<Map<String, dynamic>> updateJournal(
    int id, {
    required String title,
    required String content,
    String mood = '',
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/journal/$id'),
      headers: await _authHeaders(),
      body: jsonEncode({'title': title, 'content': content, 'mood': mood}),
    );
    return jsonDecode(response.body);
  }

  /// DELETE /journal/<id> — hapus jurnal
  static Future<Map<String, dynamic>> deleteJournal(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/journal/$id'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // ASSESSMENT
  // ════════════════════════════════════════════════

  /// POST /assessment — simpan hasil assessment
  static Future<Map<String, dynamic>> saveAssessment(int score) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assessment'),
      headers: await _authHeaders(),
      body: jsonEncode({'score': score}),
    );
    return jsonDecode(response.body);
  }

  /// GET /assessment — ambil riwayat assessment
  static Future<Map<String, dynamic>> getAssessments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/assessment'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }

  // ════════════════════════════════════════════════
  // CHATBOT
  // ════════════════════════════════════════════════

  /// POST /chatbot — kirim pesan ke chatbot
  static Future<Map<String, dynamic>> sendChatMessage(String message) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chatbot'),
      headers: await _authHeaders(),
      body: jsonEncode({'message': message}),
    );
    return jsonDecode(response.body);
  }

  /// GET /chatbot/history — ambil riwayat chat
  static Future<Map<String, dynamic>> getChatHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/chatbot/history'),
      headers: await _authHeaders(),
    );
    return jsonDecode(response.body);
  }
}