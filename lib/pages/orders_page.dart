import 'package:customer/pages/all_orders_page.dart';
import 'package:customer/util/cards.dart';
import 'package:customer/util/format.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:flutter/material.dart';

/// The logged-in customer's own orders.
class OrdersPage extends StatelessWidget {
  final int userId;
  const OrdersPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MY ORDERS'),
        elevation: 10,
        actions: [
          IconButton(
            tooltip: 'All orders',
            icon: const Icon(Icons.all_inbox),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllOrdersPage()),
            ),
          ),
        ],
      ),
      body: RemoteList(
        load: () => loadOrders(buyerOrdersUrl(userId)),
        itemWidth: 340,
        emptyIcon: Icons.shopping_bag_outlined,
        emptyMessage: "You haven't placed any orders yet.\n"
            'Pick something from Home to get started.',
        searchHint: 'Search by item, farmer or status',
        matches: orderMatches,
        headerBuilder: (orders) {
          if (orders.isEmpty) return const SizedBox.shrink();
          final spent =
              orders.fold<double>(0, (s, o) => s + toDouble(o['final_amount']));
          final pending = orders.fold<double>(
              0, (s, o) => s + toDouble(o['amount_pending']));
          return SummaryCard([
            ('Orders', '${orders.length}'),
            ('Total', formatMoney(spent)),
            ('Pending', formatMoney(pending)),
          ]);
        },
        itemBuilder: (context, order) => OrderCard(order: order),
      ),
    );
  }
}
