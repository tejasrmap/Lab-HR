import 'package:flutter_test/flutter_test.dart';
import 'package:stock_inventory_app/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const StockInventoryApp());
    expect(find.byType(StockInventoryApp), findsOneWidget);
  });
}
