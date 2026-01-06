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

  StreamSubscription<ConnectivityResult>? _connectivitySub;
  Timer? _debounceTimer;

  void _init() {
    Logger().d('NetworkService: init');
    // emit a conservative initial value (assume offline) so listeners have a value
    _controller.add(false);
    // perform initial real check
    _check();
    // also query connectivity once to log state
    Connectivity().checkConnectivity().then((result) => Logger().d('NetworkService: initial connectivity result $result'));
    // listen connectivity changes and verify real internet access
    _connectivitySub = Connectivity().onConnectivityChanged.listen((e) {
      Logger().d('NetworkService: connectivity change detected: $e');
      // debounce rapid connectivity events
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _check();
      });
    });
  }

  Future<void> _check() async {
    try {
      Logger().d('NetworkService: performing internet connection check...');
      final hasConnection = await InternetConnectionChecker().hasConnection;
      Logger().d('NetworkService: hasConnection = $hasConnection');
      _controller.add(hasConnection);
    } catch (e) {
      Logger().e('NetworkService: error during check: $e');
      _controller.add(false);
    }
  }

  /// Public API to force a connectivity re-check.
  Future<void> refresh() async => _check();

  void dispose() {
    _connectivitySub?.cancel();
    _debounceTimer?.cancel();
    _controller.close();
  }
}
