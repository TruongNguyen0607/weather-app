import 'package:flutter_test/flutter_test.dart';
import 'package:global_weather/main.dart';

void main() {
  testWidgets('shows the mobile weather navigation', (tester) async {
    await tester.pumpWidget(
      const WeatherApp(autoLocate: false, enablePersistence: false),
    );
    await tester.pump();

    expect(find.text('Weather starts with a place'), findsOneWidget);
    expect(find.text('Weather'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Countries'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
  });
}
