import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:customer/util/ipfile.dart';

/// The demo server sleeps when idle and takes up to ~90 s to start again,
/// so requests wait this long before giving up.
const serverTimeout = Duration(minutes: 2);

/// Lets the wake-up notice be shown from anywhere. Set on MaterialApp.
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

extension ServerWait<T> on Future<T> {
  /// Waits up to [timeout] for the server. If it takes longer than
  /// [noticeAfter] (usually because the server is waking up), shows a notice
  /// until the request finishes. [onSlow] replaces the notice (used in tests).
  Future<T> waitForServer({
    Duration timeout = serverTimeout,
    Duration noticeAfter = const Duration(seconds: 6),
    void Function()? onSlow,
  }) {
    ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? notice;
    final timer = Timer(noticeAfter, () {
      if (onSlow != null) {
        onSlow();
        return;
      }
      notice = scaffoldMessengerKey.currentState?.showSnackBar(const SnackBar(
        content: Text('Waking up the server. This can take up to a minute…'),
        duration: Duration(minutes: 2),
      ));
    });
    return this.timeout(timeout).whenComplete(() {
      timer.cancel();
      notice?.close();
    });
  }
}

/// Sends a request as soon as the app opens so a sleeping server starts
/// waking up while the user is still on the first screen.
void wakeUpServer() {
  http.get(Uri.parse(apiUrl('inventory'))).timeout(serverTimeout).then(
        (_) {},
        onError: (_) {},
      );
}
