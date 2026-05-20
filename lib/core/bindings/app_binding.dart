import 'package:get/get.dart';
import '../../data/providers/assessment_provider.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AssessmentProvider(), permanent: true);
  }
}
