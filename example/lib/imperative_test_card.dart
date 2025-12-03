import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

/// Imperative behavior test - demonstrates persistence with null indexToScrollTo.
class ImperativeTestCard extends StatefulWidget {
  final int globalCount;

  const ImperativeTestCard({super.key, required this.globalCount});

  @override
  State<ImperativeTestCard> createState() => _ImperativeTestCardState();
}

class _ImperativeTestCardState extends State<ImperativeTestCard> {
  final IndexedScrollController _controller = IndexedScrollController();
  String _status = 'Ready to test';
  int? _currentIndex; // Visual highlight of scrolled-to index

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
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.touch_app_rounded,
                      color: Colors.indigo, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Imperative Test',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      Text(
                          'indexToScrollTo: null - controller persists across rebuilds',
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
                onScrolledTo: (idx) {
                  // Update status to reflect scrolls (programmatic or declarative)
                  setState(() {
                    _status = 'Scrolled to $idx';
                    _currentIndex = idx;
                  });
                },
                indexToScrollTo: null, // Imperative control only
                itemBuilder: (context, index) => Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: index == _currentIndex
                        ? Colors.indigo.withValues(alpha: 0.15)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: index == _currentIndex
                        ? Border.all(color: Colors.indigo, width: 2)
                        : null,
                    boxShadow: index == _currentIndex
                        ? [
                            BoxShadow(
                              color: Colors.indigo.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ListTile(
                    dense: true,
                    leading: index == _currentIndex
                        ? const Icon(Icons.location_on_rounded,
                            color: Colors.indigo)
                        : CircleAvatar(
                            backgroundColor:
                                Colors.indigo.withValues(alpha: 0.1),
                            child: Text('$index',
                                style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                )),
                          ),
                    title: Text('Item #$index',
                        style: TextStyle(
                          fontWeight: index == _currentIndex
                              ? FontWeight.bold
                              : FontWeight.normal,
                        )),
                    trailing: index == _currentIndex
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('HERE',
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        setState(() => _status = 'Scrolling to index 30...');
                        await _controller.scrollToIndex(
                          30,
                          itemCount: widget.globalCount,
                        );
                        setState(() => _status = 'At 30');
                      },
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Scroll to 30'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                        foregroundColor: Colors.indigo,
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        setState(() => _status = 'Scrolling to index 5...');
                        await _controller.scrollToIndex(
                          5,
                          itemCount: widget.globalCount,
                        );
                        setState(() => _status = 'At 5');
                      },
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Scroll to 5'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.indigo.withValues(alpha: 0.1),
                        foregroundColor: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_status,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.indigo,
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
}
