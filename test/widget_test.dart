import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:capstone6/modules/auth/otp_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OtpView shows verification flow when started from register', (
    tester,
  ) async {
    Get.testMode = true;
    Get.arguments = {'email': 'test@example.com', 'fromRegister': true};

    await tester.pumpWidget(const MaterialApp(home: OtpView()));

    expect(find.text('Verifikasi akun'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
  });
}
