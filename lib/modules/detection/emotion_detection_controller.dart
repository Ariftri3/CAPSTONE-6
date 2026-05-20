import 'package:get/get.dart';

class EmotionDetectionController extends GetxController {
  final detectedEmotion = 'Bahagia'.obs;
  final confidence = 92.obs;

  void detectEmotion() {
    detectedEmotion.value = 'Tenang';
    confidence.value = 88;
  }
}
