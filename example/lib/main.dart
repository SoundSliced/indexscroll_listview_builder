import 'package:flutter/material.dart';
import 'package:indexscroll_listview_builder/indexscroll_listview_builder.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IndexScrollListViewBuilder Demo',
      theme: ThemeData.light(useMaterial3: true),
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
  final IndexedScrollController _externalController = IndexedScrollController();

  int _autoScrollTarget = 25; // initial auto-scroll target
  int _dynamicScrollTarget = 10; // for external controller demo
  int _offset = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IndexScrollListViewBuilder Demo')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Basic usage (no auto-scroll):',
              style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 150,
            child: IndexScrollListViewBuilder(
              itemCount: 30,
              itemBuilder: (context, index) => Card(
                child: ListTile(title: Text('Basic Item #$index')),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Auto-scroll to index $_autoScrollTarget with offset $_offset:',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 150,
            child: IndexScrollListViewBuilder(
              itemCount: 50,
              indexToScrollTo: _autoScrollTarget,
              numberOfOffsetedItemsPriorToSelectedItem: _offset,
              scrollAlignment: 0.2,
              showScrollbar: true,
              scrollbarThumbVisibility: true,
              itemBuilder: (context, index) => Container(
                color: index == _autoScrollTarget ? Colors.amberAccent : null,
                child: ListTile(
                  title: Text('Auto Item #$index'),
                  subtitle:
                      index == _autoScrollTarget ? const Text('Target') : null,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => setState(
                    () => _autoScrollTarget = (_autoScrollTarget + 5) % 50),
                child: const Text('Next Target +5'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _offset = (_offset + 1) % 5),
                child: const Text('Change Offset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('External controller scroll to $_dynamicScrollTarget:',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(
            height: 200,
            child: IndexScrollListViewBuilder(
              controller: _externalController,
              itemCount: 100,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemBuilder: (context, index) => ListTile(
                title: Text('Extern Item #$index'),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () async {
                  setState(() =>
                      _dynamicScrollTarget = (_dynamicScrollTarget + 10) % 100);
                  await _externalController.scrollToIndex(_dynamicScrollTarget,
                      alignmentOverride: 0.3);
                },
                child: const Text('Scroll +10'),
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _dynamicScrollTarget =
                      (_dynamicScrollTarget - 10) < 0
                          ? 0
                          : _dynamicScrollTarget - 10);
                  await _externalController.scrollToIndex(_dynamicScrollTarget,
                      alignmentOverride: 0.7);
                },
                child: const Text('Scroll -10'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _externalController.scrollToIndex(99,
                      alignmentOverride: 1.0);
                },
                child: const Text('Scroll Last'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
