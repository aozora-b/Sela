import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sela/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('cold launch lands on Home screen with pick CTA', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: SelaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Video'), findsOneWidget);
    expect(find.text('Beranda'), findsWidgets);
  });
}
