import 'package:flutter/material.dart';
import 'package:fancy_scrollbar/fancy_scrollbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fancy Scrollbar',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Fancy Scrollbar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: ScrollExample(),
      ),
    );
  }
}

class ScrollExample extends StatefulWidget {
  const ScrollExample({super.key});

  @override
  State<ScrollExample> createState() => _ScrollExampleState();
}

class _ScrollExampleState extends State<ScrollExample> {
  int selectedIndex = 0;

  final List<({IconData icon, String label, Color color})> items = const [
    (icon: Icons.home, label: 'Home', color: Colors.blue),
    (icon: Icons.favorite, label: 'Favorite', color: Colors.red),
    (icon: Icons.settings, label: 'Settings', color: Colors.green),
    (icon: Icons.person, label: 'Profile', color: Colors.purple),
    (icon: Icons.notifications, label: 'Notifications', color: Colors.orange),
    (icon: Icons.mail, label: 'Mail', color: Colors.teal),
    (icon: Icons.camera, label: 'Camera', color: Colors.indigo),
    (icon: Icons.music_note, label: 'Music', color: Colors.pink),
    (icon: Icons.movie, label: 'Movies', color: Colors.amber),
    (icon: Icons.book, label: 'Books', color: Colors.cyan),
    (icon: Icons.shopping_cart, label: 'Cart', color: Colors.deepOrange),
    (icon: Icons.restaurant, label: 'Food', color: Colors.lightGreen),
    (icon: Icons.directions_car, label: 'Transport', color: Colors.brown),
    (icon: Icons.flight, label: 'Travel', color: Colors.blueGrey),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FancyScrollBar(
          itemSpacing: 10,
          onSelectionChanged: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          selectedIndex: selectedIndex,
          viewportHeight: 80,
          indicatorColor: Theme.of(context)
              .colorScheme
              .primary, // Use theme color for indicator
          items: [
            for (final (index, item) in items.indexed)
              Container(
                height: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.icon,
                        size: 32,
                        color: item.color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
        const SizedBox(height: 160),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<int>(selectedIndex),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[selectedIndex].icon,
                  size: 120,
                  color: items[selectedIndex].color,
                ),
                const SizedBox(height: 24),
                Text(
                  items[selectedIndex].label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
