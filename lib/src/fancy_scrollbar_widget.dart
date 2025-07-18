part of '../fancy_scrollbar.dart';

/// Duration for regular scroll animations
const _alignDuration = Duration(milliseconds: 200);

/// Duration for snap-to-position animations
const _stickAlignDuration = Duration(milliseconds: 60);

/// A customizable horizontal scrollbar widget with an animated indicator.
///
/// This widget provides a horizontal scrollable list of items with a smooth
/// animated indicator that follows the selected item. It's perfect for
/// navigation menus, tab bars, and other horizontal scrolling interfaces.
///
/// Example usage:
/// ```dart
/// FancyScrollBar(
///   itemSpacing: 16.0,
///   onSelectionChanged: (index) {
///     print('Selected item at index: $index');
///   },
///   selectedIndex: 0,
///   items: [
///     Text('Item 1'),
///     Text('Item 2'),
///     Text('Item 3'),
///   ],
/// )
/// ```
class FancyScrollBar extends StatefulWidget {
  /// The horizontal spacing between items in the scrollbar.
  final double itemSpacing;

  /// Optional scroll controller for manual control of the scrolling behavior.
  final ScrollController? controller;

  /// Callback function that is called when the selected index changes.
  final Function(int) onSelectionChanged;

  /// The initially selected item index.
  final int selectedIndex;

  /// The height of the indicator bar below the items.
  ///
  /// Defaults to 2.0 if not specified.
  final double? indicatorHeight;

  /// The color of the indicator bar below the items.
  ///
  /// Defaults to Colors.black if not specified.
  final Color? indicatorColor;

  /// The height of the scrollable view containing the items.
  ///
  /// Defaults to 60.0 if not specified.
  final double? viewportHeight;

  /// The list of widget items to display in the scrollbar.
  final List<Widget> items;

  /// Creates a FancyScrollBar widget.
  ///
  /// The [itemSpacing], [onSelectionChanged], [selectedIndex], and [items]
  /// parameters are required.
  const FancyScrollBar({
    super.key,
    required this.itemSpacing,
    required this.onSelectionChanged,
    required this.selectedIndex,
    required this.items,
    this.viewportHeight,
    this.indicatorHeight,
    this.indicatorColor,
    this.controller,
  });

  @override
  State<FancyScrollBar> createState() => _FancyScrollBarState();
}

class _FancyScrollBarState extends State<FancyScrollBar> {
  final List<double> thresholdPathsForNextItem = [];
  final selectedIndex = ValueNotifier(0);
  final lastOperationIndex = ValueNotifier(0);
  final scrollDistance = ValueNotifier(0.0);
  final scrollPercent = ValueNotifier(0.0);
  final leftContainer = ValueNotifier(_ScrollParams(offset: 0.0));
  final indicatorWidth = ValueNotifier(_ScrollParams(offset: 0.0));
  final scrollEndDebounce =
      _Debounce(duration: const Duration(milliseconds: 20));
  final fetchResultsDebounce =
      _Debounce(duration: const Duration(milliseconds: 500));
  final notifySelectedIndexCubitListeners = ValueNotifier(true);

  late final keys = widget.items.map((e) => GlobalKey()).toList();

  final parentKey = GlobalKey();

  late final double viewportWidth;

  late final scrollController = widget.controller ?? ScrollController();

  late final List<double> obtainedWidths;
  late final double obtainedTotalWidth;

  double get maxScrollExtent => scrollController.position.maxScrollExtent;

  void initialiseThresholdsForNextItemArray() {
    double sum = 0;

    for (final width in obtainedWidths) {
      thresholdPathsForNextItem.add(
        sum +
            (width / 2) +
            (width * ((sum + (width / 2)) / obtainedTotalWidth)),
      );
      sum += width;
    }
  }

  void initialisePostFrameValues() {
    viewportWidth =
        (parentKey.currentContext!.findRenderObject() as RenderBox).size.width;

    obtainedWidths = keys.map((key) {
      RenderBox renderbox = key.currentContext!.findRenderObject() as RenderBox;
      return renderbox.size.width;
    }).toList();

    obtainedTotalWidth = obtainedWidths.reduce((value, width) => value + width);
  }

  // late final StreamSubscription<SimpleValue<int>> subscription;

  void resetAnimationTypes({_ScrollType type = _ScrollType.animate}) {
    leftContainer.value = leftContainer.value.copyWith(type: type);
    indicatorWidth.value = indicatorWidth.value.copyWith(type: type);
  }

  void onIndexChanged(int index) {
    widget.onSelectionChanged(index);
    lastOperationIndex.value = index;
  }

  void onIndexChangedListener() {
    if (!notifySelectedIndexCubitListeners.value) {
      return;
    }
    fetchResultsDebounce.run(() {
      onIndexChanged(selectedIndex.value);
    });
  }

  @override
  void initState() {
    selectedIndex.addListener(onIndexChangedListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      initialisePostFrameValues();
      initialiseThresholdsForNextItemArray();
      indicatorWidth.value = _ScrollParams(
        offset: obtainedWidths[selectedIndex.value],
        type: _ScrollType.noAnimate,
      );

      scrollController.addListener(scrollListener);
      await onItemClick(widget.selectedIndex, isInitialIndex: true);
      await Future.delayed(const Duration(milliseconds: 100));
      resetAnimationTypes();
    });
    super.initState();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      scrollController.dispose();
    }
    selectedIndex.removeListener(onIndexChangedListener);
    selectedIndex.dispose();
    lastOperationIndex.dispose();
    scrollDistance.dispose();
    scrollPercent.dispose();
    leftContainer.dispose();
    indicatorWidth.dispose();
    notifySelectedIndexCubitListeners.dispose();

    super.dispose();
  }

  void scrollListener() {
    scrollPercent.value = scrollController.offset / maxScrollExtent;

    scrollDistance.value = scrollPercent.value * obtainedTotalWidth;

    var index = thresholdPathsForNextItem
        .indexWhere((path) => path >= scrollDistance.value);

    if (index == -1) {
      index = thresholdPathsForNextItem.length - 1;
    }

    if (index != selectedIndex.value) {
      selectedIndex.value = index;
    }

    indicatorWidth.value = indicatorWidth.value.copyWith(
      offset: obtainedWidths[selectedIndex.value],
    );
    leftContainer.value = leftContainer.value.copyWith(
      offset:
          scrollPercent.value * (viewportWidth - indicatorWidth.value.offset),
    );
  }

  Future<void> onItemClick(int index, {bool isInitialIndex = false}) async {
    if (index == selectedIndex.value) {
      return;
    }
    notifySelectedIndexCubitListeners.value = false;
    selectedIndex.value = index;
    onIndexChanged(index);
    await autoAlign(
        type: isInitialIndex ? _ScrollType.noAnimate : _ScrollType.animate);
    notifySelectedIndexCubitListeners.value = true;

    if (lastOperationIndex.value != selectedIndex.value) {
      onIndexChanged(selectedIndex.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: widget.viewportHeight ?? 60,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                scrollEndDebounce.run(() async {
                  await autoAlign(type: _ScrollType.clamp);
                });
              }
              return true;
            },
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              key: parentKey,
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (index, item) in widget.items.indexed)
                    GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        key: keys[index],
                        onTap: () {
                          onItemClick(index);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: widget.itemSpacing),
                          child: item,
                        ))
                ],
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            ValueListenableBuilder(
              valueListenable: leftContainer,
              builder: (context, leftContainerParams, child) => AnimatedPadding(
                duration: leftContainerParams.type.toDuration,
                padding:
                    EdgeInsets.only(left: max(leftContainerParams.offset, 0)),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: indicatorWidth,
              builder: (context, tabSizeParams, child) => AnimatedContainer(
                margin: EdgeInsets.only(left: widget.itemSpacing),
                width: max(tabSizeParams.offset - (2 * widget.itemSpacing), 0),
                duration: tabSizeParams.type.toDuration,
                height: widget.indicatorHeight ?? 2,
                decoration: BoxDecoration(
                  border: Border.all(width: 0),
                  color: widget.indicatorColor ?? Colors.black,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(100)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> autoAlign({
    _ScrollType type = _ScrollType.animate,
  }) async {
    resetAnimationTypes(type: type);
    final offset = getEquivalentScrollOffest(
      thresholdPathsForNextItem.elementAt(selectedIndex.value) -
          (obtainedWidths[selectedIndex.value] / 2),
    );

    if (type == _ScrollType.noAnimate) {
      scrollController.jumpTo(offset);
      await Future.delayed(const Duration(milliseconds: 100));
    } else {
      await scrollController.animateTo(
        offset,
        duration: type.toDuration,
        curve: Curves.easeIn,
      );
    }
    resetAnimationTypes();
  }

  double getEquivalentScrollOffest(double path) {
    return (path * maxScrollExtent) / obtainedTotalWidth;
  }
}

class _ScrollParams {
  final double offset;
  final _ScrollType type;

  _ScrollParams({
    required this.offset,
    this.type = _ScrollType.animate,
  });

  _ScrollParams copyWith({
    double? offset,
    _ScrollType? type,
  }) {
    return _ScrollParams(
      offset: offset ?? this.offset,
      type: type ?? this.type,
    );
  }
}

enum _ScrollType {
  clamp,
  animate,
  noAnimate;

  Duration get toDuration {
    switch (this) {
      case _ScrollType.animate:
        return _alignDuration;
      case _ScrollType.clamp:
        return _stickAlignDuration;
      case _ScrollType.noAnimate:
        return Duration.zero;
    }
  }
}
