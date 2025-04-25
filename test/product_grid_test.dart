import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qtech_shopping_app/presentation/widgets/product_grid.dart';

void main() async {
  testWidgets('ProductGrid shows search field', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProductGrid(),
        ),
      ),
    );
    final searchField = find.byWidgetPredicate((widget) =>
    widget is TextField && widget.decoration?.hintText == 'Search Anything...');

    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'Shoes');
    await tester.pump();

    expect(find.text('Shoes'), findsOneWidget);

  });
}