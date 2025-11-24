/// A Flutter package providing an enhanced ListView.builder with index-based scrolling.
///
/// This library exports the main widget [IndexScrollListViewBuilder] which extends
/// Flutter's standard ListView.builder with the ability to programmatically scroll
/// to any item by its index, even if that item hasn't been built yet.
///
/// Key features:
/// * Programmatic scrolling to any item by index
/// * Smooth, configurable animations
/// * Automatic handling of edge cases (first/last items)
/// * Optional scrollbar support with full customization
/// * Smart constraint handling for unbounded layouts
/// * Customizable item alignment in viewport
///
/// Example:
/// ```dart
/// import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';
///
/// IndexScrollListViewBuilder(
///   itemCount: 100,
///   indexToScrollTo: 50, // Automatically scroll to item 50
///   itemBuilder: (context, index) {
///     return ListTile(title: Text('Item $index'));
///   },
/// )
/// ```
///
/// See also:
///  * [IndexScrollListViewBuilder], the main widget
///  * [IndexedScrollController], for advanced programmatic control
library;

export 'src/indexscroll_listview_builder.dart';
export 'src/indexed_scroll_controller.dart';
export 'src/indexed_scroll_child.dart';
