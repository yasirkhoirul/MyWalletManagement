import 'dart:async';

/// Types of toast notifications
enum ToastType { success, error, info, syncing }

/// A toast notification message
class ToastMessage {
  final String message;
  final ToastType type;
  final Duration duration;

  ToastMessage({
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 3),
  });
}

/// Service to manage queued toast notifications
/// Ensures notifications display one at a time without overlapping
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _controller = StreamController<ToastMessage?>.broadcast();
  final List<ToastMessage> _queue = [];
  bool _isShowing = false;

  /// Stream of current notification to display
  Stream<ToastMessage?> get stream => _controller.stream;

  /// Add a notification to the queue
  void show(ToastMessage message) {
    _queue.add(message);
    _processQueue();
  }

  /// Show sync in progress
  void showSyncing() {
    show(
      ToastMessage(
        message: 'Syncing...',
        type: ToastType.syncing,
        duration: const Duration(
          seconds: 30,
        ), // Long duration, will be replaced
      ),
    );
  }

  /// Show sync success
  void showSyncSuccess([String message = 'Synced!']) {
    // Remove any syncing message first
    _queue.removeWhere((m) => m.type == ToastType.syncing);
    show(
      ToastMessage(
        message: message,
        type: ToastType.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show sync error
  void showSyncError([String message = 'Sync Failed']) {
    // Remove any syncing message first
    _queue.removeWhere((m) => m.type == ToastType.syncing);
    show(
      ToastMessage(
        message: message,
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show transaction success
  void showTransactionSuccess([String message = 'Transaksi berhasil!']) {
    show(
      ToastMessage(
        message: message,
        type: ToastType.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show transaction error
  void showTransactionError([String message = 'Transaksi gagal']) {
    show(
      ToastMessage(
        message: message,
        type: ToastType.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show generic info
  void showInfo(String message) {
    show(
      ToastMessage(
        message: message,
        type: ToastType.info,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Clear current and pending notifications
  void clear() {
    _queue.clear();
    _isShowing = false;
    _controller.add(null);
  }

  void _processQueue() {
    if (_isShowing || _queue.isEmpty) return;

    _isShowing = true;
    final message = _queue.removeAt(0);
    _controller.add(message);

    // Auto-hide after duration (unless it's syncing which stays until replaced)
    if (message.type != ToastType.syncing) {
      Future.delayed(message.duration, () {
        _isShowing = false;
        _controller.add(null);
        // Process next in queue after a small delay
        Future.delayed(const Duration(milliseconds: 300), () {
          _processQueue();
        });
      });
    } else {
      // Syncing stays visible, but allow new messages to replace it
      _isShowing = false;
    }
  }

  void dispose() {
    _controller.close();
  }
}
