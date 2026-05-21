import 'dart:async';

/// Simple event bus for course-related changes.
class CourseEventBus {
  CourseEventBus._();

  static final StreamController<void> _controller = StreamController<void>.broadcast();

  /// Stream you can listen to for course changes.
  static Stream<void> get stream => _controller.stream;

  /// Notify listeners that courses changed (create/update/delete/archive).
  static void notify() {
    try {
      _controller.add(null);
    } catch (_) {}
  }

  /// Close the controller (not used in app runtime).
  static Future<void> dispose() async {
    await _controller.close();
  }
}
