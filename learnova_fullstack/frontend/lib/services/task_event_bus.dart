import 'dart:async';

/// Simple event bus for task-related changes.
class TaskEventBus {
  TaskEventBus._();

  static final StreamController<void> _controller = StreamController<void>.broadcast();

  /// Stream you can listen to for task changes.
  static Stream<void> get stream => _controller.stream;

  /// Notify listeners that tasks changed (create/update/delete).
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
