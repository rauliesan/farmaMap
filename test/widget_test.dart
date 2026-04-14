// Basic smoke test for FarmaMap Sevilla
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:farma_map/main.dart';

void main() {
  testWidgets('FarmaMapApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FarmaMapApp(),
      ),
    );

    // Verify the app at least renders (map screen is the initial route)
    expect(find.byType(FarmaMapApp), findsOneWidget);
  });
}
