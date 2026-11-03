
import 'package:flutter_test/flutter_test.dart';
import 'package:exp_1/main.dart';

void main() {
  testWidgets('Fruit Store application test',
      (WidgetTester tester) async {

    await tester.pumpWidget(const FruitApp());

    expect(find.text('Fruit Store'), findsOneWidget);
    expect(find.text('Available Fruits'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
  });
}
