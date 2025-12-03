import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

/// Declarative behavior test - demonstrates indexToScrollTo as "home position".
class DeclarativeTestCard extends StatefulWidget {
  final int globalCount;

  const DeclarativeTestCard({super.key, required this.globalCount});

  @override
  State<DeclarativeTestCard> createState() => _DeclarativeTestCardState();
}

class _DeclarativeTestCardState extends State<DeclarativeTestCard> {
  final IndexedScrollController _controller = IndexedScrollController();
  int? _declarativeIndex = 15;
  String _status = 'Ready to test';

  @override
  void didUpdateWidget(DeclarativeTestCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep home position within valid bounds when globalCount changes
    if (_declarativeIndex != null && _declarativeIndex! >= widget.globalCount) {
      _declarativeIndex = widget.globalCount - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Card header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.home_rounded,
                      color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Declarative Test',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      Text(
                          'indexToScrollTo: ${_declarativeIndex ?? 'null'} - ${_declarativeIndex != null ? 'restores on rebuild' : 'imperative mode'}',
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
            // List content
            Container(
              height: 280,
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: IndexScrollListViewBuilder(
                controller: _controller,
                itemCount: widget.globalCount,
                indexToScrollTo:
                    _declarativeIndex, // Declarative index position
                onScrolledTo: (idx) {
                  // Always update the declarative index to follow any scroll.
                  // IndexScrollListViewBuilder intelligently prevents this from
                  // cancelling imperative scrolls.
                  if (_declarativeIndex == null || _declarativeIndex == idx) {
                    // No change or in imperative mode; skip redundant setState.
                    return;
                  }
                  setState(() {
                    _declarativeIndex = idx;
                    _status = 'Scrolled to $idx — index updated';
                  });
                },
                itemBuilder: (context, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: index == _declarativeIndex
                        ? Colors.teal.withValues(alpha: 0.2)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: index == _declarativeIndex
                        ? Border.all(color: Colors.teal, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    dense: true,
                    leading: index == _declarativeIndex
                        ? const Icon(Icons.home, color: Colors.teal)
                        : Text('$index', style: const TextStyle(fontSize: 12)),
                    title: Text('Item #$index',
                        style: TextStyle(
                          fontWeight: index == _declarativeIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                    trailing: index == _declarativeIndex
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.teal,
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
            const SizedBox(height: 16),
            // Controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSliderControl(
                  context,
                  icon: Icons.home,
                  label: 'Home Position',
                  value: (_declarativeIndex ?? 15).toDouble(),
                  displayValue:
                      _declarativeIndex != null ? '$_declarativeIndex' : 'null',
                  min: 0,
                  max: (widget.globalCount - 1).toDouble(),
                  divisions: (widget.globalCount - 1).clamp(1, 199).toInt(),
                  color: Colors.teal,
                  onChanged: (v) =>
                      setState(() => _declarativeIndex = v.toInt()),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Imperative scroll to index 40
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        // Simply scroll imperatively.
                        // The onScrolledTo callback will update _declarativeIndex,
                        // and the widget intelligently prevents scroll cancellation.
                        setState(() {
                          _status = 'Scrolling to 40 (imperative)...';
                        });
                        await _controller.scrollToIndex(
                          40,
                          itemCount: widget.globalCount,
                        );
                        setState(() {
                          _status =
                              'At 40 — index auto-updated via onScrolledTo';
                        });
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Scroll to 40'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.teal.withValues(alpha: 0.1),
                        foregroundColor: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_status,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.teal,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
