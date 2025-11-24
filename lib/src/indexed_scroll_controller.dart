import 'package:flutter/material.dart';
import 'package:post_frame/post_frame.dart';

/// A specialized scroll controller that enables programmatic scrolling to specific
/// indexed items within a scrollable list.
///
/// This controller extends the functionality of a standard [ScrollController] by
/// maintaining a registry of [GlobalKey]s associated with list item indices. This
/// allows for precise scrolling to any item in the list by its index, even if the
/// item hasn't been built yet or is off-screen.
///
/// The controller uses [Scrollable.ensureVisible] to smoothly animate the scroll
/// position and bring the target item into view. It includes intelligent handling
/// for edge cases like scrolling to the last item in a list.
///
/// Example usage:
/// ```dart
/// final controller = IndexedScrollController(
///   duration: Duration(milliseconds: 300),
///   alignment: 0.2, // Position item at 20% from top
/// );
///
/// // Later, scroll to index 10
/// controller.scrollToIndex(10);
/// ```
///
/// See also:
///  * [IndexedScrollTag], which registers items with this controller
///  * [IndexScrollListViewBuilder], which integrates this controller with ListView
class IndexedScrollController {
  /// Creates an [IndexedScrollController].
  ///
  /// All parameters are optional and have sensible defaults.
  ///
  /// * [scrollController]: The underlying scroll controller. If null, a new one is created.
  /// * [duration]: Default animation duration when scrolling to an index (default: 400ms).
  /// * [curve]: The animation curve to use for scrolling (default: [Curves.easeOut]).
  /// * [alignment]: The vertical/horizontal alignment of the target item (0.0 to 1.0).
  ///   - 0.0 aligns the item at the start (top/left)
  ///   - 0.5 centers the item
  ///   - 1.0 aligns the item at the end (bottom/right)
  ///   Default is 0.2 (20% from the start).
  /// * [alignmentPolicy]: Determines how the scroll position is adjusted.
  /// * [endOfFramePasses]: Number of frame passes to wait at end of scroll (default: 12).
  /// * [maxFramePasses]: Maximum number of frames to wait before scrolling (default: 15).
  IndexedScrollController({
    ScrollController? scrollController,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
    this.alignment = 0.2,
    this.alignmentPolicy = ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    this.endOfFramePasses = 12,
    this.maxFramePasses = 15,
  }) : _scrollController = scrollController ?? ScrollController();

  /// The underlying scroll controller used for actual scrolling operations.
  final ScrollController _scrollController;

  /// Default animation duration for scroll operations.
  final Duration duration;

  /// Default animation curve for scroll operations.
  final Curve curve;

  /// Default alignment for positioning items in the viewport (0.0 to 1.0).
  final double alignment;

  /// Default policy for aligning items in the viewport.
  final ScrollPositionAlignmentPolicy alignmentPolicy;

  /// Registry of [GlobalKey]s for each indexed item.
  /// Sparse list where null entries indicate unregistered indices.
  final List<GlobalKey?> _registeredKeys = <GlobalKey?>[];

  /// Number of frame passes to wait at the end of a scroll operation.
  final int endOfFramePasses;

  /// Maximum number of frames to wait before initiating a scroll operation.
  final int maxFramePasses;

  /// Provides access to the underlying [ScrollController].
  ///
  /// Use this to access standard scroll controller properties like
  /// position, offset, or to attach listeners.
  ScrollController get controller => _scrollController;

  /// Registers a [GlobalKey] for a specific item index.
  ///
  /// This method is typically called by [IndexedScrollTag] widgets to register
  /// themselves with the controller. The registered key allows the controller
  /// to locate and scroll to the corresponding item.
  ///
  /// * [index]: The item's position in the list (must be non-negative).
  /// * [key]: The [GlobalKey] associated with the item.
  ///
  /// If [index] is negative, the registration is silently ignored.
  /// The internal registry automatically expands to accommodate new indices.
  void registerKey({required int index, required GlobalKey key}) {
    // Ignore negative indices
    if (index < 0) {
      return;
    }

    // Expand the registry if necessary to accommodate this index
    if (_registeredKeys.length <= index) {
      _registeredKeys.length = index + 1;
    }
    _registeredKeys[index] = key;
  }

  /// Updates a key's registration from an old index to a new index.
  ///
  /// This is useful when list items are reordered or when the same widget
  /// changes its position in the list. The method safely handles the transition
  /// by first removing the old registration and then adding the new one.
  ///
  /// * [oldIndex]: The previous index (can be null if this is a new registration).
  /// * [newIndex]: The new index for this key.
  /// * [key]: The [GlobalKey] being moved.
  ///
  /// If [oldIndex] is null or invalid, only the new registration is performed.
  void updateKeyIndex({
    required int? oldIndex,
    required int newIndex,
    required GlobalKey key,
  }) {
    // Remove the old registration if it exists and matches
    if (oldIndex != null &&
        oldIndex >= 0 &&
        oldIndex < _registeredKeys.length &&
        _registeredKeys[oldIndex] == key) {
      _registeredKeys[oldIndex] = null;
    }

    // Register at the new index
    registerKey(index: newIndex, key: key);
  }

  /// Unregisters a [GlobalKey] from the controller.
  ///
  /// This is typically called when a widget is being disposed. The method
  /// removes the key from the registry and trims any trailing null entries
  /// to keep the registry compact.
  ///
  /// * [key]: The [GlobalKey] to unregister.
  ///
  /// If the key is not found, this method has no effect.
  void unregisterKey(GlobalKey key) {
    final index = _registeredKeys.indexOf(key);
    if (index != -1) {
      _registeredKeys[index] = null;
      // Clean up trailing nulls to prevent unbounded growth
      _trimTrailingNulls();
    }
  }

  /// Internal method that performs the actual scroll operation.
  ///
  /// This method resolves the target index, retrieves the associated widget's
  /// context, and uses [Scrollable.ensureVisible] to scroll it into view.
  ///
  /// Special handling for the last item in the list:
  /// - Uses alignment of 2.0 (overscroll to ensure full visibility)
  /// - Uses [ScrollPositionAlignmentPolicy.keepVisibleAtEnd] policy
  ///
  /// Returns immediately if the index cannot be resolved or if the widget
  /// context is not available (e.g., widget not yet built).
  Future<void> _scrollToIndex(
    int index, {
    Duration? durationOverride,
    Curve? curveOverride,
    double? alignmentOverride,
    ScrollPositionAlignmentPolicy? alignmentPolicyOverride,
  }) async {
    // Resolve the requested index to the nearest available registered index
    final safeIndex = _resolveIndex(index);
    if (safeIndex == null) {
      return; // No registered items available
    }

    // Get the key and its current build context
    final key = _registeredKeys[safeIndex];
    final context = key?.currentContext;
    if (context == null) {
      return; // Widget not yet built or disposed
    }

    // Determine if we're scrolling to the last item for special handling
    final lastRegisteredIndex = _lastRegisteredIndex();
    final isLastItem =
        lastRegisteredIndex != null && safeIndex == lastRegisteredIndex;

    // Perform the scroll operation with appropriate parameters
    // Last items get special treatment to ensure they're fully visible
    await Scrollable.ensureVisible(
      context,
      duration: durationOverride ?? duration,
      curve: curveOverride ?? curve,
      alignment: alignmentOverride ?? (isLastItem ? 2.0 : alignment),
      alignmentPolicy: alignmentPolicyOverride ??
          (isLastItem
              ? ScrollPositionAlignmentPolicy.keepVisibleAtEnd
              : alignmentPolicy),
    );
  }

  /// Scrolls to the item at the given [index] with animation.
  ///
  /// This is the primary method for programmatically scrolling to a specific
  /// item. It uses [PostFrame.postFrame] to ensure the target widget has been
  /// built and laid out before attempting to scroll.
  ///
  /// The method intelligently handles several edge cases:
  /// - If the exact index isn't registered, it finds the nearest available index
  /// - Automatically waits for widgets to be built before scrolling
  /// - Special handling for scrolling to the last item in the list
  ///
  /// Parameters:
  /// * [index]: The target item's index (will be clamped to available range).
  /// * [duration]: Animation duration (overrides default if provided).
  /// * [curveOverride]: Animation curve (overrides default if provided).
  /// * [alignmentOverride]: Viewport alignment (overrides default if provided).
  /// * [alignmentPolicyOverride]: Alignment policy (overrides default if provided).
  /// * [maxFrameDelay]: Maximum frames to wait before scrolling (default: 15).
  /// * [endOfFrameDelay]: Frames to wait at end of scroll (default: 12).
  ///
  /// Returns a [Future] that completes when the scroll animation finishes.
  ///
  /// Example:
  /// ```dart
  /// // Scroll to index 20 with custom duration
  /// await controller.scrollToIndex(
  ///   20,
  ///   duration: Duration(milliseconds: 500),
  ///   alignmentOverride: 0.5, // Center the item
  /// );
  /// ```
  Future<void> scrollToIndex(
    int index, {
    Duration? duration,
    Curve? curveOverride,
    double? alignmentOverride,
    ScrollPositionAlignmentPolicy? alignmentPolicyOverride,
    int? maxFrameDelay,
    int? endOfFrameDelay,
  }) {
    return PostFrame.postFrame(
      scrollControllers: [_scrollController],
      maxWaitFrames: maxFrameDelay ?? maxFramePasses,
      endOfFramePasses: endOfFrameDelay ?? endOfFramePasses,
      () => _scrollToIndex(
        index,
        durationOverride: duration,
        curveOverride: curveOverride,
        alignmentOverride: alignmentOverride,
        alignmentPolicyOverride: alignmentPolicyOverride,
      ),
    );
  }

  /// Resolves a desired index to the nearest registered index.
  ///
  /// This method implements intelligent index resolution with fallback logic:
  /// 1. Collects all currently registered (non-null) indices
  /// 2. Clamps the desired index to the available range
  /// 3. If the exact index exists, returns it
  /// 4. Otherwise, searches outward (down then up) for the nearest registered index
  ///
  /// This ensures that scroll operations can always find a valid target, even if
  /// not all items have been built yet (e.g., during initial render or dynamic lists).
  ///
  /// Returns:
  /// * The resolved index if any registered indices exist
  /// * `null` if no indices are currently registered
  int? _resolveIndex(int desiredIndex) {
    // Collect all currently registered indices
    final available = <int>[];
    for (var i = 0; i < _registeredKeys.length; i++) {
      if (_registeredKeys[i] != null) {
        available.add(i);
      }
    }

    // No registered items available
    if (available.isEmpty) {
      return null;
    }

    // Clamp the desired index to the available range
    final min = available.first;
    final max = available.last;
    var clamped = desiredIndex;
    if (clamped < min) {
      clamped = min;
    } else if (clamped > max) {
      clamped = max;
    }

    // If the exact index is registered, use it
    if (_registeredKeys[clamped] != null) {
      return clamped;
    }

    // Search downward for the nearest registered index
    for (var lower = clamped - 1; lower >= min; lower--) {
      if (_registeredKeys[lower] != null) {
        return lower;
      }
    }

    // Search upward for the nearest registered index
    for (var upper = clamped + 1; upper <= max; upper++) {
      if (_registeredKeys[upper] != null) {
        return upper;
      }
    }

    // Theoretically unreachable since available is not empty
    return null;
  }

  /// Removes trailing null entries from the registered keys list.
  ///
  /// This optimization prevents the internal list from growing unbounded when
  /// items at the end are removed. It's called after unregistering keys to
  /// maintain a compact memory footprint.
  void _trimTrailingNulls() {
    while (_registeredKeys.isNotEmpty && _registeredKeys.last == null) {
      _registeredKeys.removeLast();
    }
  }

  /// Finds the highest index with a registered key.
  ///
  /// This is used to detect when scrolling to the last item in the list,
  /// which requires special handling to ensure full visibility.
  ///
  /// Returns:
  /// * The highest registered index
  /// * `null` if no keys are registered
  int? _lastRegisteredIndex() {
    for (var i = _registeredKeys.length - 1; i >= 0; i--) {
      if (_registeredKeys[i] != null) {
        return i;
      }
    }
    return null;
  }
}
