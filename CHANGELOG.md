## 2.0.1

* Version 2.0.1

## 2.0.0

### 🚀 Major Improvements

#### Fixed
* **Bidirectional auto-scrolling**: Fixed critical bug where scrolling only worked downward (to lower indices). Now works perfectly in both directions.
* **External controller scrolling**: Fixed issue where external controller buttons (First, Last, +10, -10) would scroll the outer page instead of the inner ListView.
* **Last item visibility**: Improved handling to ensure the last item in the list is fully visible when scrolled to.
* **Rapid scroll cancellation**: Added operation versioning to cancel superseded scroll operations, preventing "short scrolls" during rapid slider drags.

#### Enhanced
* **Viewport-based scrolling**: Replaced `Scrollable.ensureVisible` with direct viewport offset calculations using `RenderAbstractViewport.getOffsetToReveal` for precise control and to prevent scrolling ancestor scrollables.
* **Off-screen item handling**: Implemented smart position estimation for items not yet rendered, enabling smooth scrolling to any index.
* **Performance optimization**: Added fast-path optimization in index resolution that checks exact index existence before building the full available list.
* **Production-ready code**: Updated all documentation to accurately reflect the viewport-based implementation, improved edge case handling.

#### Added
* `itemCount` parameter to `scrollToIndex()` method for better off-screen position estimation.
* Comprehensive inline documentation improvements across all source files.
* Better error handling and edge case documentation.

### 🛠 Technical Details
* Controller now uses scroll position's `maxScrollExtent` for reliable last-item scrolling
* Operation versioning mechanism prevents interrupted scroll animations
* Smart extremes handling: index 0 → offset 0.0, last index → maxScrollExtent

### 📦 Example App
* Updated example app with proper `pubspec.yaml` to enable hot reload/restart
* All external controller buttons now work correctly with itemCount parameter
* Demonstrates all new improvements in action

### ⚠️ Breaking Changes
**Minor**: The `scrollToIndex()` method now requires an `itemCount` parameter for optimal off-screen scrolling. Existing code needs to be updated:

```dart
// Before (v1.x)
controller.scrollToIndex(50);

// After (v2.0.0)
controller.scrollToIndex(50, itemCount: totalItems);
```

## 1.0.0

### Added
* Comprehensive inline documentation for all public APIs.
* Exported controller (`IndexedScrollController`) and tag widget (`IndexedScrollTag`) from root library.
* Example application demonstrating basic usage, auto-scroll, offset, and external controller patterns.
* Widget tests for build, auto-scroll triggering, and external controller scrolling.
* MIT License file.

### Improved
* README with full feature list, installation, usage snippets, API overview, and parameters table.
* Pubspec description and metadata (repository, issue tracker).

### Notes
* Stable 1.0.0 release – API considered ready for production use.

## 0.0.1

* Initial release
