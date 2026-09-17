import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks whether the device currently has *some* network interface up
/// (wifi/mobile/ethernet). This is reachability, not "Firestore is
/// reachable" — a captive portal or a dead upstream link still reports
/// `true` here. It's enough to tell the user "you're offline" instead of
/// letting every screen guess that from a failed request.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit(this._connectivity) : super(true) {
    _connectivity.checkConnectivity().then(_onResult);
    _subscription = _connectivity.onConnectivityChanged.listen(_onResult);
  }

  final Connectivity _connectivity;
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  void _onResult(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (!isClosed) emit(online);
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
