import 'package:customer/pages/all_payment_page.dart';
import 'package:customer/util/cards.dart';
import 'package:customer/util/format.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:flutter/material.dart';

/// The logged-in customer's own payments.
class PaymentPage extends StatelessWidget {
  final int userId;
  const PaymentPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY PAYMENTS'),
        elevation: 10,
        actions: [
          IconButton(
            tooltip: 'All payments',
            icon: const Icon(Icons.all_inbox),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllPaymentPage()),
            ),
          ),
        ],
      ),
      body: RemoteList(
        load: () => loadPayments(buyerPaymentsUrl(userId)),
        itemWidth: 340,
        emptyIcon: Icons.account_balance_wallet_outlined,
        emptyMessage: 'No payments yet.',
        searchHint: 'Search by farmer or method',
        matches: paymentMatches,
        headerBuilder: (payments) {
          if (payments.isEmpty) return const SizedBox.shrink();
          final paid = payments.fold<double>(
              0, (s, p) => s + toDouble(p['payment_amount']));
          return SummaryCard([
            ('Payments', '${payments.length}'),
            ('Total paid', formatMoney(paid)),
          ]);
        },
        itemBuilder: (context, payment) => PaymentCard(payment: payment),
      ),
    );
  }
}
