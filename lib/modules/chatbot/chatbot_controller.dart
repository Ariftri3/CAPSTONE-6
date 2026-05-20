import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatbotController extends GetxController {
  final messages = <ChatMessage>[
    ChatMessage(
      text:
          'Halo! Ceritakan bagaimana perasaanmu hari ini? Aku siap mendengarkan.',
      isUser: false,
    ),
    ChatMessage(
      text: 'Akhir-akhir capek banget hari ini, merasa berat banget semuanya.',
      isUser: true,
    ),
    ChatMessage(
      text:
          'Aku mengerti sekali perasaanmu. Wajar jika kamu merasa lelah setelah hari yang panjang. Ingatlah bahwa kamu sudah berusaha yang terbaik, dan tidak apa-apa untuk beristirahat sejenak.',
      isUser: false,
    ),
  ].obs;
  final replyController = TextEditingController();

  void sendMessage() {
    final message = replyController.text.trim();
    if (message.isEmpty) return;
    messages.add(ChatMessage(text: message, isUser: true));
    replyController.clear();
    Future.delayed(const Duration(milliseconds: 450), () {
      messages.add(
        ChatMessage(
          text:
              'Terima kasih telah berbagi. Saya merekomendasikan latihan relaksasi ringan.',
          isUser: false,
        ),
      );
    });
  }
}
