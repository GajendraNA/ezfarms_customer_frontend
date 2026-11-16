import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:customer/util/server_wakeup.dart';

void main() {
  test('waits for a slow (sleeping) server instead of failing', () async {
    var noticed = false;
    final result = await Future.delayed(const Duration(milliseconds: 300), () => 'ok')
        .waitForServer(
      timeout: const Duration(seconds: 2),
      noticeAfter: const Duration(milliseconds: 50),
      onSlow: () => noticed = true,
    );
    expect(result, 'ok');
    expect(noticed, isTrue, reason: 'a slow request should show the wake-up notice');
  });

  test('fast responses show no wake-up notice', () async {
    var noticed = false;
    await Future.value('ok').waitForServer(
      noticeAfter: const Duration(milliseconds: 50),
      onSlow: () => noticed = true,
    );
    await Future.delayed(const Duration(milliseconds: 100));
    expect(noticed, isFalse);
  });

  test('default wait covers a Render free-tier cold start (~90 s)', () {
    expect(serverTimeout, greaterThanOrEqualTo(const Duration(seconds: 100)));
  });

  test('still gives up eventually', () {
    expect(
      Future.delayed(const Duration(milliseconds: 300))
          .waitForServer(timeout: const Duration(milliseconds: 50), onSlow: () {}),
      throwsA(isA<TimeoutException>()),
    );
  });
}
