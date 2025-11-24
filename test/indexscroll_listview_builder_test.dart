import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

void main() {
  group('IndexScrollListViewBuilder', () {
    testWidgets('builds list items', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: IndexScrollListViewBuilder(
            itemCount: 10,
            itemBuilder: (context, index) => Text('Item $index'),
          ),
        ),
      ));

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 9'), findsOneWidget);
    });

    testWidgets('auto scroll triggers without error', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: IndexScrollListViewBuilder(
            itemCount: 50,
            indexToScrollTo: 25,
            numberOfOffsetedItemsPriorToSelectedItem: 2,
            itemBuilder: (context, index) => Text('Auto $index'),
          ),
        ),
      ));

      // Allow frames for post frame callback
      await tester.pumpAndSettle(const Duration(seconds: 1));
      // Just ensure target exists and no exceptions occurred
      expect(find.text('Auto 25'), findsOneWidget);
    });

    testWidgets('external controller scrollToIndex executes', (tester) async {
      final controller = IndexedScrollController();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: IndexScrollListViewBuilder(
            controller: controller,
            itemCount: 100,
            itemBuilder: (context, index) => Text('X $index'),
          ),
        ),
      ));

      await tester.pump();

      // Use runAsync to allow scroll future
      await tester.runAsync(() async {
        await controller.scrollToIndex(75);
      });

      // Ensure some item text is still accessible
      expect(find.text('X 75'), findsOneWidget);
    });
  });
}
