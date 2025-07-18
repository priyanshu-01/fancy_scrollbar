# Fancy Scrollbar

A customizable horizontal scrollbar widget for Flutter that provides smooth scrolling with an animated indicator. Perfect for navigation menus, tab bars, and other horizontal scrolling interfaces.

## Features

- Smooth horizontal scrolling with animated indicator
- Customizable item spacing and indicator appearance
- Customizable indicator color
- Support for any widget as scrollable items
- Snap-to-item behavior
- Optional manual scroll control via ScrollController
- Responsive to both tap and scroll gestures

## Getting started

Add this package to your Flutter project by including it in your `pubspec.yaml`:

```yaml
dependencies:
  fancy_scrollbar: ^0.0.1
```

## Usage

Here's a simple example of how to use the FancyScrollBar widget:

```dart
import 'package:fancy_scrollbar/fancy_scrollbar.dart';

FancyScrollBar(
  itemSpacing: 16.0,
  onSelectionChanged: (index) {
    setState(() {
      selectedIndex = index;
    });
  },
  // initialSelectedIndex defaults to 0 if not specified
  indicatorColor: Colors.blue, // Optional: customize indicator color
  items: [
    Text('Item 1'),
    Text('Item 2'),
    Text('Item 3'),
  ],
)
```

### Parameters

- `itemSpacing`: The horizontal spacing between items in the scrollbar
- `onSelectionChanged`: Callback function that is called when the selected index changes
- `items`: List of widget items to display in the scrollbar
- `initialSelectedIndex`: Optional initial selected item index (defaults to 0)
- `viewportHeight`: Optional height of the scrollable view (defaults to 60.0)
- `indicatorHeight`: Optional height of the indicator bar (defaults to 2.0)
- `indicatorColor`: Optional color of the indicator bar (defaults to Colors.black)
- `controller`: Optional ScrollController for manual scroll control

### Example with Icons

Check out the example folder for a complete implementation showing how to create a navigation menu with icons:

```dart
FancyScrollBar(
  itemSpacing: 10.0,
  onSelectionChanged: (index) {
    setState(() {
      selectedIndex = index;
    });
  },
  initialSelectedIndex: 2, // Start with the third item selected
  viewportHeight: 80,
  indicatorColor: Theme.of(context).primaryColor, // Use theme color
  items: [
    for (final item in menuItems)
      Column(
        children: [
          Icon(item.icon),
          Text(item.label),
        ],
      ),
  ],
)
```

## Additional information

- Report bugs on the [GitHub issues page](https://github.com/yourusername/fancy_scrollbar/issues)
- Contribute to the package by creating pull requests
- For more examples and documentation, visit the [GitHub repository](https://github.com/yourusername/fancy_scrollbar)
