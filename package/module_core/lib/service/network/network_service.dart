import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logger/web.dart';

/// NetworkService provides a simple stream of online/offline status.
///
/// Usage:
/// final svc = NetworkService();
/// svc.onStatus.listen((online) => ...);
class NetworkService {
  NetworkService._internal() {
    _init();
  }

  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get onStatus => _controller.stream;

  StreamSubscription<dynamic>? _connectivitySub;
  Timer? _debounceTimer;
  Timer? _periodicTimer;
  bool _lastKnownStatus =
      true; // Assume online initially until proven otherwise
  bool _hasEmittedInitial = false;

  void _init() {
    // Perform initial real check immediately
    _checkInitial();

    // Listen to connectivity changes and verify real internet access
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      // debounce rapid connectivity events
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _check();
      });
    });

    // Periodic check every 30 seconds to handle edge cases
    _periodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _check();
    });
  }

  /// Initial check that always emits status
  Future<void> _checkInitial() async {
    try {
      // Wait a bit for system to stabilize on app start
      await Future.delayed(const Duration(milliseconds: 500));

      // Check actual internet connection directly
      final hasConnection = await InternetConnectionChecker().hasConnection;
      _lastKnownStatus = hasConnection;
      _hasEmittedInitial = true;
      _controller.add(hasConnection);
      Logger().d(
        'NetworkService: initial check = ${hasConnection ? "ONLINE" : "OFFLINE"}',
      );
    } catch (e) {
      Logger().e('NetworkService initial check error: $e');
      // On error, emit true to not block the user
      _lastKnownStatus = true;
      _hasEmittedInitial = true;
      _controller.add(true);
    }
  }

  Future<void> _check() async {
    try {
      // First check if we have any connectivity
      final connectivityResult = await Connectivity().checkConnectivity();

      // Handle both single result and list (API changed in newer versions)
      bool hasNoConnectivity = false;
      if (connectivityResult is List) {
        hasNoConnectivity =
            (connectivityResult as List).isEmpty ||
            (connectivityResult as List).every(
              (r) => r == ConnectivityResult.none,
            );
      } else {
        hasNoConnectivity = connectivityResult == ConnectivityResult.none;
      }

      if (hasNoConnectivity) {
        _updateStatus(false);
        return;
      }

      // Verify actual internet connection
      final hasConnection = await InternetConnectionChecker().hasConnection;
      _updateStatus(hasConnection);
    } catch (e) {
      Logger().e('NetworkService check error: $e');
      // On error, keep last known status to avoid flickering
    }
  }

  void _updateStatus(bool isOnline) {
    if (_lastKnownStatus != isOnline || !_hasEmittedInitial) {
      _lastKnownStatus = isOnline;
      _hasEmittedInitial = true;
      _controller.add(isOnline);
      Logger().d(
        'NetworkService: status changed to ${isOnline ? "ONLINE" : "OFFLINE"}',
      );
    }
  }

  /// Get current status synchronously (last known)
  bool get isOnline => _lastKnownStatus;

  /// Public API to force a connectivity re-check.
  Future<void> refresh() async => _check();

  void dispose() {
    _connectivitySub?.cancel();
    _debounceTimer?.cancel();
    _periodicTimer?.cancel();
    _controller.close();
  }
}
