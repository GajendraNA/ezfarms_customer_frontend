import 'package:customer/util/cards.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:flutter/material.dart';

class AllPaymentPage extends StatelessWidget {
  const AllPaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ALL PAYMENTS'), elevation: 10),
      body: RemoteList(
        load: () => loadPayments(getAllPayments),
        itemWidth: 340,
        emptyIcon: Icons.account_balance_wallet_outlined,
        emptyMessage: 'No payments yet.',
        searchHint: 'Search by farmer, customer or method',
        matches: paymentMatches,
        itemBuilder: (context, payment) =>
            PaymentCard(payment: payment, showCustomer: true),
      ),
    );
  }
}
