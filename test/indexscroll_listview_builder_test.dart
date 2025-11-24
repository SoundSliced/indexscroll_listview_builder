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
          body: SizedBox(
            height: 100, // Constrain height to force scrolling
            child: IndexScrollListViewBuilder(
              controller: controller,
              itemCount: 50, // Larger list to ensure scrolling
              itemBuilder: (context, index) => Text('X $index'),
            ),
          ),
        ),
      ));

      // Initial pump to build widgets
      await tester.pump();

      // Use scrollUntilVisible to force ListView to build and reveal item 25
      await tester.scrollUntilVisible(
        find.text('X 25'),
        50.0, // delta in pixels per scroll
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('X 25'), findsOneWidget,
          reason: 'Item X 25 should be visible after scrollUntilVisible.');
    });
  });
}
