import 'package:get/get.dart';
import 'emotion_detection_controller.dart';

class EmotionDetectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(EmotionDetectionController());
  }
}
