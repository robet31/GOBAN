import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goban/features/auth/screens/onboarding_screen.dart';

void main() {
  testWidgets('onboarding presents the three promised product benefits',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    expect(find.text('Cari bengkel di sekitar Anda'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);

    await tester.tap(find.text('Berikutnya'));
    await tester.pumpAndSettle();
    expect(find.text('Bantuan darurat yang dapat dilacak'), findsOneWidget);

    await tester.tap(find.text('Berikutnya'));
    await tester.pumpAndSettle();
    expect(find.text('Setujui biaya dengan jelas'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
  });

  testWidgets('onboarding calls completion when skipped',
      (WidgetTester tester) async {
    var completed = false;
    await tester.pumpWidget(MaterialApp(
      home: OnboardingScreen(onComplete: () async => completed = true),
    ));

    await tester.tap(find.text('Lewati'));
    await tester.pump();

    expect(completed, isTrue);
  });
}
