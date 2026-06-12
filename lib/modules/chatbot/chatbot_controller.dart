import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatbotController extends GetxController {
  final messages      = <ChatMessage>[].obs;
  final isTyping      = false.obs; // animasi "sedang mengetik..."
  final replyController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Pesan sambutan awal
    messages.add(ChatMessage(
      text: 'Halo! Ceritakan bagaimana perasaanmu hari ini? Aku siap mendengarkan. 💙',
      isUser: false,
    ));
    loadHistory();
  }

  /// Muat riwayat chat dari backend
  Future<void> loadHistory() async {
    try {
      final result = await ApiService.getChatHistory();
      if (result['success'] == true) {
        final List history = result['data'];
        // Konversi riwayat ke format ChatMessage
        final List<ChatMessage> loaded = [];
        for (final h in history) {
          loaded.add(ChatMessage(text: h['message'], isUser: true));
          loaded.add(ChatMessage(text: h['reply'],   isUser: false));
        }
        if (loaded.isNotEmpty) {
          messages.clear();
          messages.addAll(loaded);
        }
      }
    } catch (_) {
      // Tetap tampilkan pesan sambutan jika gagal load
    }
  }

  /// Kirim pesan ke backend dan tampilkan balasan
  Future<void> sendMessage() async {
    final message = replyController.text.trim();
    if (message.isEmpty) return;

    // Tampilkan pesan user
    messages.add(ChatMessage(text: message, isUser: true));
    replyController.clear();

    // Tampilkan animasi mengetik
    isTyping.value = true;

    try {
      final result = await ApiService.sendChatMessage(message);
      isTyping.value = false;

      if (result['success'] == true) {
        messages.add(ChatMessage(
          text: result['data']['reply'],
          isUser: false,
        ));
      } else {
        messages.add(ChatMessage(
          text: 'Maaf, ada gangguan. Coba lagi ya.',
          isUser: false,
        ));
      }
    } catch (e) {
      isTyping.value = false;
      messages.add(ChatMessage(
        text: 'Tidak dapat terhubung ke server. Periksa koneksi kamu.',
        isUser: false,
      ));
    }
  }

  @override
  void onClose() {
    replyController.dispose();
    super.onClose();
  }
}
