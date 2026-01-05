import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthListerner extends ChangeNotifier {
  late final StreamSubscription _subscription;

  AuthListerner(BlocBase mybloc){
    _subscription = mybloc.stream.listen((event) => notifyListeners(),);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}