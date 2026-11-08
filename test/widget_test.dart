import 'package:customer/pages/login_page.dart';
import 'package:customer/util/format.dart';
import 'package:customer/util/responsive.dart';
import 'package:customer/util/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('format helpers', () {
    test('money uses rupees with two decimals', () {
      expect(formatMoney(1234.5), '₹1,234.50');
      expect(formatMoney(null), 'N/A');
    });

    test('weights drop a trailing .0', () {
      expect(formatKg(2.0), '2 kg');
      expect(formatKg(2.5), '2.50 kg');
    });

    test('dates accept strings and Java LocalDate arrays', () {
      expect(formatDate('2024-05-01'), '1 May 2024');
      expect(formatDate([2024, 5, 1]), '1 May 2024');
      expect(apiDate(DateTime(2024, 5, 1, 13, 30)), '2024-05-01');
    });

    test('toDouble handles ints, strings and junk', () {
      expect(toDouble(3), 3.0);
      expect(toDouble('4.5'), 4.5);
      expect(toDouble(null), 0);
    });
  });

  group('validators', () {
    test('email', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail('abc'), isNotNull);
      expect(validateEmail('a@b.com'), isNull);
    });

    test('phone', () {
      expect(validatePhone('123'), isNotNull);
      expect(validatePhone('98765 43210'), isNull);
      expect(validatePhone('+919876543210'), isNull);
    });
  });

  testWidgets('login shows validation errors instead of calling the server',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('RemoteList uses more columns on wider screens', (tester) async {
    Future<void> pumpAt(double width) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: RemoteList(
            key: UniqueKey(),
            itemWidth: 300,
            load: () async => [
              for (var i = 0; i < 6; i++) {'id': i}
            ],
            itemBuilder: (context, item) =>
                SizedBox(height: 50, child: Text('item ${item['id']}')),
          ),
        ),
      ));
      await tester.pumpAndSettle();
    }

    addTearDown(tester.view.reset);

    await pumpAt(400);
    final phoneY = tester.getTopLeft(find.text('item 1')).dy;
    expect(phoneY, greaterThan(tester.getTopLeft(find.text('item 0')).dy));

    await pumpAt(1000);
    // Items 0-2 share a row on a wide screen.
    expect(tester.getTopLeft(find.text('item 2')).dy,
        tester.getTopLeft(find.text('item 0')).dy);
  });
}
