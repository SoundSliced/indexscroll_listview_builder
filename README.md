# indexscroll_listview_builder

Enhanced `ListView.builder` for Flutter with powerful index-based programmatic scrolling, item alignment control, offset handling, and optional customizable scrollbar.

## ✨ Features

* Scroll directly to any item by its index (even if not yet built)
* Automatic initial scroll via `indexToScrollTo`
* Offset support: keep items before the target visible (`numberOfOffsetedItemsPriorToSelectedItem`)
* Customizable alignment of target item in viewport (`scrollAlignment`)
* External controller for advanced programmatic control (`IndexedScrollController`)
* Optional scrollbar with full customization (thumb, track, thickness, radius, orientation)
* Smart `shrinkWrap` handling for unbounded constraints
* Smooth animations with configurable duration and curve
* Special handling for last item visibility
* Frame-delayed scroll execution to reduce layout jank

## 🛠 Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  indexscroll_listview_builder: ^1.0.0
```

Then import:

```dart
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';
```

## 🚀 Quick Start

```dart
IndexScrollListViewBuilder(
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(title: Text('Item #$index')),
)
```

## 🎯 Auto Scroll on Build

Automatically scroll to a target index when the widget builds:

```dart
IndexScrollListViewBuilder(
  itemCount: 50,
  indexToScrollTo: 25, // scroll after first frame
  numberOfOffsetedItemsPriorToSelectedItem: 2, // keep previous 2 items visible
  itemBuilder: (context, index) => ListTile(
    title: Text('Item #$index'),
  ),
)
```

## 🧭 External Controller

Use an `IndexedScrollController` for programmatic control:

```dart
final controller = IndexedScrollController();

IndexScrollListViewBuilder(
  controller: controller,
  itemCount: 100,
  itemBuilder: (context, index) => ListTile(title: Text('Item #$index')),
);

// Later (e.g. button press)
await controller.scrollToIndex(75, alignmentOverride: 0.3);
```

## 🪟 Scrollbar Example

```dart
IndexScrollListViewBuilder(
  itemCount: 80,
  showScrollbar: true,
  scrollbarThumbVisibility: true,
  scrollbarThickness: 8,
  scrollbarRadius: const Radius.circular(8),
  itemBuilder: (context, index) => ListTile(title: Text('Item #$index')),
)
```

## 📐 Alignment & Offset

`scrollAlignment` controls where the item appears in the viewport (0.0 = start, 0.5 = center, 1.0 = end).

`numberOfOffsetedItemsPriorToSelectedItem` shifts the effective scroll position backward so prior items remain visible.

## 🧪 Example Application

See the complete example in `example/lib/main.dart` with:

* Basic list
* Auto-scroll with dynamic target & offset
* External controller demo with buttons
* Scroll to last item handling

## 🔍 API Overview

### `IndexScrollListViewBuilder`
Primary widget combining builder pattern with index-based scrolling.

### `IndexedScrollController`
Maintains a registry of item keys and performs smart index resolution & animated scrolling.

### `IndexedScrollTag`
Internal widget used to tag and register each item in the list.

## ⚙ Parameters (Highlights)

| Parameter | Description |
|-----------|-------------|
| `indexToScrollTo` | Auto-scroll target after build |
| `numberOfOffsetedItemsPriorToSelectedItem` | Items kept visible before target |
| `scrollAlignment` | Alignment of target (0.0–1.0) |
| `controller` | External scrolling controller |
| `showScrollbar` | Wrap list with customizable scrollbar |
| `scrollbarThumbVisibility` | Force thumb visibility |
| `suppressPlatformScrollbars` | Hide default platform scrollbars |

## 📄 CHANGELOG

See `CHANGELOG.md` for detailed version history.

## 📜 License

Licensed under the MIT License. See `LICENSE`.

## 🔗 Repository & Issues

Repository: https://github.com/SoundSliced/indexscroll_listview_builder  
Issues: https://github.com/SoundSliced/indexscroll_listview_builder/issues

## 🙌 Contributing

Contributions welcome! Feel free to open issues or PRs for improvements, examples, or documentation refinements.

---
If this package helps you, a ⭐ on GitHub is appreciated!
