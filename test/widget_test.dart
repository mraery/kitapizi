import 'package:flutter_test/flutter_test.dart';
import 'package:kitapizi/main.dart';

void main() {
  testWidgets('KitapIziApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KitapIziApp());
    expect(find.text('Kitapİzi'), findsOneWidget);
  });
}
