import 'package:customer/util/cards.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:flutter/material.dart';

class AllOrdersPage extends StatelessWidget {
  const AllOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ALL ORDERS'), elevation: 10),
      body: RemoteList(
        load: () => loadOrders(getAllOrdersUrl),
        itemWidth: 340,
        emptyIcon: Icons.receipt_long,
        emptyMessage: 'No orders yet.',
        searchHint: 'Search by item, farmer, customer or status',
        matches: orderMatches,
        itemBuilder: (context, order) =>
            OrderCard(order: order, showCustomer: true),
      ),
    );
  }
}
