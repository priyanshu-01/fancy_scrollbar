part of '../fancy_scrollbar.dart';

class _Debounce {
  final Duration duration;
  Timer? _timer;

  _Debounce({required this.duration});

  void run(final void Function() callback) {
    if (_timer != null) {
      _timer!.cancel();
    }

    _timer = Timer(duration, callback);
  }
}
