import 'package:customer/util/api.dart';
import 'package:customer/util/format.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:flutter/material.dart';

/// Loads orders from [url], newest first. The backend leaves `item_name`
/// empty on orders, so it is filled in from the inventory list.
Future<List<Json>> loadOrders(String url) async {
  final results = await Future.wait([
    getJsonList(url),
    getJsonList(getAllInventoryUrl).catchError((_) => <Json>[]),
  ]);
  final itemNames = {
    for (final inv in results[1]) inv['id']: inv['item_name'],
  };
  final orders = results[0];
  for (final o in orders) {
    o['item_name'] ??= itemNames[o['inventory_id']];
  }
  orders.sort((a, b) {
    final da = parseDate(a['ordered_date']);
    final db = parseDate(b['ordered_date']);
    if (da == null || db == null) {
      return toDouble(b['id']).compareTo(toDouble(a['id']));
    }
    final byDate = db.compareTo(da);
    return byDate != 0 ? byDate : toDouble(b['id']).compareTo(toDouble(a['id']));
  });
  return orders;
}

bool orderMatches(Json o, String q) =>
    '${o['item_name']} ${o['farmer_name']} ${o['buyer_name']} ${o['status']}'
        .toLowerCase()
        .contains(q);

Color _statusColor(String status) {
  final s = status.toLowerCase();
  if (s.contains('deliver') || s.contains('complete')) return Colors.green;
  if (s.contains('cancel') || s.contains('reject')) return Colors.grey;
  if (s.contains('ship') || s.contains('dispatch') || s.contains('transit')) {
    return Colors.blue;
  }
  return Colors.orange;
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Json order;

  /// Show who bought it (for the all-orders view).
  final bool showCustomer;

  const OrderCard({super.key, required this.order, this.showCustomer = false});

  @override
  Widget build(BuildContext context) {
    final o = order;
    final pending = toDouble(o['amount_pending']);
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              getImageUrl(o['picture']),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported,
                    size: 48, color: Colors.grey),
              ),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        o['item_name'] ?? 'Order #${o['id'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip((o['status'] ?? '').toString()),
                  ],
                ),
                const SizedBox(height: 8),
                InfoRow(
                    icon: Icons.scale,
                    label: 'Weight',
                    value: formatKg(o['weight'])),
                InfoRow(
                    icon: Icons.currency_rupee,
                    label: 'Rate',
                    value: '${formatMoney(o['item_rate'])}/kg'),
                InfoRow(
                    icon: Icons.receipt,
                    label: 'Total',
                    value: o['final_amount'] != null &&
                            toDouble(o['final_amount']) !=
                                toDouble(o['order_amount'])
                        ? '${formatMoney(o['final_amount'])} '
                            '(was ${formatMoney(o['order_amount'])})'
                        : formatMoney(o['order_amount'])),
                if (pending > 0)
                  InfoRow(
                      icon: Icons.hourglass_bottom,
                      label: 'Pending',
                      value: formatMoney(pending),
                      color: Colors.orange[800]),
                InfoRow(
                    icon: Icons.agriculture,
                    label: 'Farmer',
                    value: o['farmer_name'] ?? 'N/A'),
                if (showCustomer)
                  InfoRow(
                      icon: Icons.person,
                      label: 'Customer',
                      value: o['buyer_name'] ?? 'N/A'),
                InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Ordered',
                    value: formatDate(o['ordered_date'])),
                InfoRow(
                    icon: Icons.local_shipping,
                    label: 'Delivery by',
                    value: formatDate(o['est_delivery_date'])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<Json>> loadPayments(String url) async {
  final payments = await getJsonList(url);
  payments.sort((a, b) {
    final da = parseDate(a['payment_date']);
    final db = parseDate(b['payment_date']);
    if (da == null || db == null) return 0;
    return db.compareTo(da);
  });
  return payments;
}

bool paymentMatches(Json p, String q) =>
    '${p['farmerName']} ${p['buyerName']} ${p['method']}'
        .toLowerCase()
        .contains(q);

class PaymentCard extends StatelessWidget {
  final Json payment;
  final bool showCustomer;

  const PaymentCard(
      {super.key, required this.payment, this.showCustomer = false});

  @override
  Widget build(BuildContext context) {
    final p = payment;
    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Icon(Icons.payments, color: Colors.green[800]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatMoney(p['payment_amount']),
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(formatDate(p['payment_date']),
                          style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
                if (p['method'] != null) Chip(label: Text('${p['method']}')),
              ],
            ),
            const Divider(),
            InfoRow(
                icon: Icons.agriculture,
                label: 'Farmer',
                value: p['farmerName'] ?? 'N/A'),
            if (showCustomer)
              InfoRow(
                  icon: Icons.person,
                  label: 'Customer',
                  value: p['buyerName'] ?? 'N/A'),
            InfoRow(
                icon: Icons.receipt,
                label: 'Order amount',
                value: formatMoney(p['order_amount'])),
            InfoRow(
                icon: Icons.money,
                label: 'Final amount',
                value: formatMoney(p['final_amount'])),
            if (p['order_id'] != null)
              InfoRow(
                  icon: Icons.tag, label: 'Order', value: '#${p['order_id']}'),
          ],
        ),
      ),
    );
  }
}

/// A small summary card, e.g. "Total paid".
class SummaryCard extends StatelessWidget {
  final List<(String, String)> stats;
  const SummaryCard(this.stats, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.red[100],
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 24,
            runSpacing: 12,
            children: [
              for (final (label, value) in stats)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(value,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(label, style: TextStyle(color: Colors.grey[800])),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
