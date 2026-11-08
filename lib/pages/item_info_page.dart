import 'package:customer/util/api.dart';
import 'package:customer/util/dialog_box.dart';
import 'package:customer/util/format.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const double discountRate = 0.05;
const int deliveryDays = 3;

class ItemInfoPage extends StatefulWidget {
  final Json inventory;
  final int userId;

  const ItemInfoPage({super.key, required this.inventory, required this.userId});

  @override
  State<ItemInfoPage> createState() => _ItemInfoPageState();
}

class _ItemInfoPageState extends State<ItemInfoPage> {
  final _weightController = TextEditingController(text: '0');
  double _orderWeight = 0;
  bool _placing = false;

  double get _available => toDouble(widget.inventory['remaining_weight']);
  double get _rate => toDouble(widget.inventory['final_rate_per_kg']);
  double get _orderAmount => _orderWeight * _rate;
  double get _discount => _orderAmount * discountRate;
  double get _finalAmount => _orderAmount - _discount;
  bool get _tooMuch => _orderWeight > _available;
  bool get _canOrder => _orderWeight > 0 && !_tooMuch && !_placing;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _setWeight(double value, {bool updateField = true}) {
    setState(() {
      _orderWeight = value < 0 ? 0 : value;
      if (updateField) {
        final v = _orderWeight;
        _weightController.text =
            v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
      }
    });
  }

  void _decrement() => _setWeight(_orderWeight - 1 < 0 ? 0 : _orderWeight - 1);

  void _increment() =>
      _setWeight(_orderWeight + 1 > _available ? _available : _orderWeight + 1);

  Future<void> _placeOrder() async {
    if (!_canOrder) return;
    final ok = await confirm(
      context,
      'Order ${formatKg(_orderWeight)} of ${widget.inventory['item_name']} '
      'for ${formatMoney(_finalAmount)}?',
      confirmLabel: 'Place order',
    );
    if (!ok || !mounted) return;

    setState(() => _placing = true);
    final now = DateTime.now();
    final order = {
      'inventory_id': widget.inventory['inven_id'],
      'farmer_id': widget.inventory['farmer_id'],
      'buyer_id': widget.userId,
      'item_id': widget.inventory['item_id'],
      'weight': _orderWeight,
      'ordered_date': apiDate(now),
      'est_delivery_date': apiDate(now.add(const Duration(days: deliveryDays))),
      'order_amount': _orderAmount,
      'discount_applied': _discount,
      'amount_pending': _finalAmount,
      'final_amount': _finalAmount,
      'status': 'order placed',
    };

    try {
      // Only reduce stock once the order has really been created.
      final created = await postJson(postOrderUrl, order);
      if (created.statusCode != 200) {
        throw ApiException(
            'Could not place the order (${created.statusCode}).');
      }

      String message = 'Order placed! Delivery in about $deliveryDays days.';
      try {
        final updated = await putJson(
          '$updateInventoryUrl/${widget.inventory['inven_id']}',
          {'remaining_weight': _available - _orderWeight},
        );
        if (updated.statusCode != 200) {
          message = 'Order placed, but the stock count was not updated.';
        }
      } on ApiException {
        message = 'Order placed, but the stock count was not updated.';
      }

      if (!mounted) return;
      showMessage(context, message);
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      showMessage(context, e.message, error: true);
    }
  }

  Widget _image(double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        getImageUrl(widget.inventory['name']),
        fit: BoxFit.cover,
        width: double.infinity,
        height: height,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.image_not_supported,
              size: 64, color: Colors.grey),
        ),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : SizedBox(
                height: height,
                child: const Center(child: CircularProgressIndicator())),
      ),
    );
  }

  Widget _priceLine(String label, String value, {bool bold = false}) {
    final style = TextStyle(
        fontSize: bold ? 18 : 15,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _details() {
    final inv = widget.inventory;
    final soldOut = _available <= 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                inv['item_name'] ?? 'Unknown',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '${formatMoney(_rate)}/kg',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[800]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        InfoRow(
            icon: Icons.person,
            label: 'Farmer',
            value: inv['farmer_name'] ?? 'Unknown',
            color: Colors.amber[800]),
        InfoRow(
            icon: Icons.description,
            label: 'About',
            value: inv['item_description'] ?? 'No description',
            color: Colors.amber[800]),
        InfoRow(
            icon: Icons.inventory,
            label: 'In stock',
            value: soldOut ? 'Sold out' : formatKg(_available),
            color: Colors.amber[800]),
        const Divider(height: 28),
        if (soldOut)
          const StatusMessage(
            icon: Icons.remove_shopping_cart,
            message: 'This item is sold out.',
          )
        else ...[
          const Text('Quantity (kg)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Remove 1 kg',
                onPressed: _orderWeight > 0 && !_placing ? _decrement : null,
                icon: const Icon(Icons.remove),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  enabled: !_placing,
                  textAlign: TextAlign.center,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    suffixText: 'kg',
                    errorText: _tooMuch
                        ? 'Only ${formatKg(_available)} available'
                        : null,
                  ),
                  onChanged: (v) =>
                      _setWeight(double.tryParse(v) ?? 0, updateField: false),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Add 1 kg',
                onPressed:
                    _orderWeight < _available && !_placing ? _increment : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _priceLine('Subtotal', formatMoney(_orderAmount)),
          _priceLine('Discount (${(discountRate * 100).round()}%)',
              '- ${formatMoney(_discount)}'),
          const Divider(),
          _priceLine('Total', formatMoney(_finalAmount), bold: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _canOrder ? _placeOrder : null,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: _placing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    )
                  : const Icon(Icons.shopping_cart_checkout),
              label: Text(
                _orderWeight > 0
                    ? 'Place Order (${formatKg(_orderWeight)})'
                    : 'Choose a quantity',
                style: const TextStyle(fontSize: 17),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ITEM INFO'), elevation: 10),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= wideBreakpoint;
            final content = wide
                // Side by side on wide screens.
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _image(380)),
                      const SizedBox(width: 24),
                      Expanded(flex: 6, child: _details()),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _image((constraints.maxHeight * 0.32).clamp(180, 320)),
                      const SizedBox(height: 16),
                      _details(),
                    ],
                  );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: MaxWidth(
                maxWidth: 1000,
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: content,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
