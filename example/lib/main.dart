// (imports and main already declared above in this file)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

void main() {
  // Entry point for the demo app.
  runApp(const DemoApp());
}

/// Small demo showcasing IndexScrollListViewBuilder features:
/// - Basic list usage
/// - Auto-scrolling to a target index
/// - Programmatic control via an external controller
class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndexScrollListViewBuilder Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Material 3 + color seed + Google Fonts (Inter).
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: GoogleFonts.inter().fontFamily,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        fontFamily: GoogleFonts.inter().fontFamily,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.light,
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  // External controller used by the "External Controller" card.
  final IndexedScrollController _externalController = IndexedScrollController();

  // Global amount of items used by two cards (auto + external).
  int _globalCount = 60;

  // Count for the basic list example.
  int _basicCount = 20;

  // Auto-scroll configuration: target index, offset, and alignment.
  int _autoTarget = 10;
  int _autoOffset = 1;
  double _autoAlignment = 0.2;

  // Tracks the current position for the externally controlled list.
  int _controlledTarget = 5;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        title: Row(
          children: [
            // App icon badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.view_list_rounded, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            // App title/subtitle
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('IndexScrollListViewBuilder',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Interactive Demo',
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
              ],
            ),
          ],
        ),
        actions: [
          // Randomize targets to demonstrate updates
          IconButton(
            icon: const Icon(Icons.shuffle_rounded),
            tooltip: 'Randomize targets',
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              foregroundColor: colorScheme.primary,
            ),
            onPressed: () {
              setState(() {
                _autoTarget = (_autoTarget + 7) % _globalCount;
                _controlledTarget = (_controlledTarget + 11) % _globalCount;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        // Decorative gradient background for the demo.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.3),
              colorScheme.secondaryContainer.withValues(alpha: 0.2),
              colorScheme.tertiaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Global Settings Card (controls number of demo items)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.settings_rounded,
                                color: colorScheme.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Text('Global Settings',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Item count display
                      Row(
                        children: [
                          Expanded(
                            child: Text('Demo item count',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('$_globalCount',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colorScheme.primary,
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Item count slider controlling _globalCount
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          min: 10,
                          max: 200,
                          divisions: 19,
                          value: _globalCount.toDouble().clamp(10, 200),
                          label: '$_globalCount items',
                          onChanged: (value) => setState(() {
                            _globalCount = value.toInt();
                            // Keep other values within valid bounds.
                            _basicCount = _basicCount.clamp(5, _globalCount);
                            _autoTarget =
                                _autoTarget.clamp(0, _globalCount - 1);
                            _controlledTarget =
                                _controlledTarget.clamp(0, _globalCount - 1);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Responsive area: 2 columns on wide screens, stacked on narrow.
                LayoutBuilder(builder: (context, constraints) {
                  final double maxWidth = constraints.maxWidth;
                  final bool twoColumns = maxWidth >= 700;
                  final double cardWidth =
                      twoColumns ? (maxWidth - 12) / 2 : maxWidth;

                  // Card 1: Basic usage without auto-scrolling or external control.
                  final Widget basicCard = _buildCard(
                    context,
                    icon: Icons.list_alt_rounded,
                    iconColor: Colors.blue,
                    title: 'Basic Usage',
                    subtitle: 'Simple list builder without auto-scroll',
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: IndexScrollListViewBuilder(
                        // Only building items, no initial scroll or controller.
                        itemCount: _basicCount,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colorScheme.shadow.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              backgroundColor:
                                  Colors.blue.withValues(alpha: 0.1),
                              child: Text('$index',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  )),
                            ),
                            title: Text('Item #$index',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: const Text('Basic list entry',
                                style: TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),
                    ),
                    footer: Column(
                      children: [
                        // Basic item-count control
                        Row(
                          children: [
                            Icon(Icons.format_list_numbered_rounded,
                                size: 16, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text('Item Count'),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('$_basicCount',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  )),
                            ),
                          ],
                        ),
                        // Slider to adjust _basicCount only
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8),
                          ),
                          child: Slider(
                            min: 5,
                            max: 50,
                            divisions: 45,
                            value: _basicCount.toDouble(),
                            activeColor: Colors.blue,
                            onChanged: (v) =>
                                setState(() => _basicCount = v.toInt()),
                          ),
                        ),
                      ],
                    ),
                  );

                  // Card 2: Auto-scroll example (scrolls on build/rebuild).
                  final Widget autoCard = _buildCard(
                    context,
                    icon: Icons.auto_awesome_motion_rounded,
                    iconColor: Colors.orange,
                    title: 'Auto-Scroll',
                    subtitle: 'Automatically scroll to target on build',
                    child: Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: IndexScrollListViewBuilder(
                        // Auto-scroll settings:
                        // - indexToScrollTo: the desired target index
                        // - numberOfOffsetedItemsPriorToSelectedItem: keep N items before target visible
                        // - scrollAlignment: 0.0 top, 0.5 center, 1.0 bottom
                        itemCount: _globalCount,
                        indexToScrollTo: _autoTarget,
                        numberOfOffsetedItemsPriorToSelectedItem: _autoOffset,
                        scrollAlignment: _autoAlignment,
                        showScrollbar: true,
                        scrollbarThumbVisibility: true,
                        shrinkWrap: true,
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            // Highlight target item visually.
                            gradient: index == _autoTarget
                                ? LinearGradient(
                                    colors: [
                                      Colors.orange.withValues(alpha: 0.3),
                                      Colors.amber.withValues(alpha: 0.2),
                                    ],
                                  )
                                : null,
                            color: index == _autoTarget
                                ? null
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: index == _autoTarget
                                ? Border.all(color: Colors.orange, width: 2)
                                : null,
                            boxShadow: index == _autoTarget
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.orange.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: colorScheme.shadow
                                          .withValues(alpha: 0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: ListTile(
                            dense: true,
                            leading: index == _autoTarget
                                ? const Icon(Icons.stars_rounded,
                                    color: Colors.orange)
                                : Icon(Icons.circle,
                                    size: 8, color: colorScheme.outline),
                            title: Text('Item #$index',
                                style: TextStyle(
                                  fontWeight: index == _autoTarget
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                )),
                            trailing: index == _autoTarget
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('TARGET',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),
                    footer: Column(
                      children: [
                        // Control: target index
                        _buildSliderControl(
                          context,
                          icon: Icons.location_searching_rounded,
                          label: 'Target Index',
                          value: _autoTarget.toDouble(),
                          displayValue: '$_autoTarget',
                          min: 0,
                          max: (_globalCount - 1).toDouble(),
                          divisions: (_globalCount - 1).clamp(1, 199).toInt(),
                          color: Colors.orange,
                          onChanged: (v) =>
                              setState(() => _autoTarget = v.toInt()),
                        ),
                        const SizedBox(height: 8),
                        // Control: offset (items before target kept visible)
                        _buildSliderControl(
                          context,
                          icon: Icons.format_indent_increase,
                          label: 'Offset',
                          value: _autoOffset.toDouble(),
                          displayValue: '$_autoOffset',
                          min: 0,
                          max: 6,
                          divisions: 6,
                          color: Colors.orange,
                          onChanged: (v) =>
                              setState(() => _autoOffset = v.toInt()),
                        ),
                        const SizedBox(height: 8),
                        // Control: alignment along viewport
                        _buildSliderControl(
                          context,
                          icon: Icons.vertical_align_center,
                          label: 'Alignment',
                          value: _autoAlignment,
                          displayValue: '${(_autoAlignment * 100).round()}%',
                          min: 0,
                          max: 1,
                          divisions: 10,
                          color: Colors.orange,
                          onChanged: (v) => setState(() => _autoAlignment = v),
                        ),
                      ],
                    ),
                  );

                  // Card 3: Programmatic control via IndexedScrollController.
                  final Widget externalCard = _buildCard(
                    context,
                    icon: Icons.control_camera_rounded,
                    iconColor: Colors.purple,
                    title: 'External Controller',
                    subtitle: 'Programmatic scroll control',
                    child: Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: IndexScrollListViewBuilder(
                        // Use the controller to call scrollToIndex() from buttons below.
                        controller: _externalController,
                        itemCount: _globalCount,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) => Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    colorScheme.shadow.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            dense: true,
                            title: Text('Item #$index',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            leading: CircleAvatar(
                              backgroundColor:
                                  Colors.purple.withValues(alpha: 0.1),
                              child: Text('$index',
                                  style: const TextStyle(
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  )),
                            ),
                            trailing: Icon(Icons.drag_indicator,
                                size: 16, color: colorScheme.outline),
                          ),
                        ),
                      ),
                    ),
                    footer: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Buttons demonstrating programmatic scrolling.
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            /// Scroll down by 10 items (wraps around)
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                setState(() => _controlledTarget =
                                    (_controlledTarget + 10) % _globalCount);
                                await _externalController.scrollToIndex(
                                  _controlledTarget,
                                  // Override default alignment for this jump.
                                  alignmentOverride: 0.3,
                                  itemCount: _globalCount,
                                );
                              },
                              icon: const Icon(Icons.arrow_downward_rounded,
                                  size: 18),
                              label: const Text('+10'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.purple.withValues(alpha: 0.1),
                                foregroundColor: Colors.purple,
                              ),
                            ),

                            /// Scroll up by 10 items (clamped at 0)
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                setState(() => _controlledTarget =
                                    (_controlledTarget - 10) < 0
                                        ? 0
                                        : _controlledTarget - 10);
                                await _externalController.scrollToIndex(
                                  _controlledTarget,
                                  alignmentOverride: 0.7,
                                  itemCount: _globalCount,
                                );
                              },
                              icon: const Icon(Icons.arrow_upward_rounded,
                                  size: 18),
                              label: const Text('-10'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.purple.withValues(alpha: 0.1),
                                foregroundColor: Colors.purple,
                              ),
                            ),

                            /// Scroll to first item
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                setState(() => _controlledTarget = 0);
                                await _externalController.scrollToIndex(
                                  0,
                                  alignmentOverride: 0.0,
                                  itemCount: _globalCount,
                                );
                              },
                              icon: const Icon(Icons.first_page_rounded,
                                  size: 18),
                              label: const Text('First'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.purple.withValues(alpha: 0.1),
                                foregroundColor: Colors.purple,
                              ),
                            ),

                            /// Scroll to last item
                            FilledButton.tonalIcon(
                              onPressed: () async {
                                setState(
                                    () => _controlledTarget = _globalCount - 1);

                                await _externalController.scrollToIndex(
                                  _globalCount - 1,
                                  alignmentOverride: 1.0,
                                  itemCount: _globalCount,
                                );
                              },
                              icon:
                                  const Icon(Icons.last_page_rounded, size: 18),
                              label: const Text('Last'),
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.purple.withValues(alpha: 0.1),
                                foregroundColor: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Current position display for the external controller.
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 16, color: Colors.purple),
                              const SizedBox(width: 8),
                              Text('Current Position: $_controlledTarget',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  // Render cards in a responsive wrap.
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      SizedBox(width: cardWidth, child: basicCard),
                      SizedBox(width: cardWidth, child: autoCard),
                      SizedBox(width: cardWidth, child: externalCard),
                    ],
                  );
                }),
                const SizedBox(height: 24),

                // Info section explaining what the demo shows.
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer.withValues(alpha: 0.5),
                        colorScheme.secondaryContainer.withValues(alpha: 0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 32, color: colorScheme.primary),
                      const SizedBox(height: 12),
                      Text(
                        'Feature Showcase',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This interactive demo showcases IndexScrollListViewBuilder\'s key features: '
                        'programmatic scrolling, index targeting, offset control, alignment options, '
                        'custom scrollbars, and external controller support.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method that builds a styled card with a header, body and optional footer.
  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required Color iconColor,
      required String title,
      String? subtitle,
      required Widget child,
      Widget? footer}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card header with icon + title (+ optional subtitle)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      if (subtitle != null)
                        Text(subtitle,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Card body content (passed as child)
            child,
            if (footer != null) ...[
              const SizedBox(height: 16),
              // Optional controls / extra content
              footer,
            ],
          ],
        ),
      ),
    );
  }

  /// Small helper to render a label + value + Slider with consistent styling.
  Widget _buildSliderControl(
    BuildContext context, {
    required IconData icon,
    required String label,
    required double value,
    required String displayValue,
    required double min,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            // Small pill showing the current value.
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(displayValue,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color,
                  )),
            ),
          ],
        ),
        // Shared slider appearance
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            min: min,
            max: max,
            divisions: divisions,
            value: value.clamp(min, max),
            activeColor: color,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
