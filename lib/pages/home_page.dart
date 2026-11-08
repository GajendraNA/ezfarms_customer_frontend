import 'package:customer/pages/all_orders_page.dart';
import 'package:customer/pages/all_payment_page.dart';
import 'package:customer/pages/customer_list_page.dart';
import 'package:customer/pages/farmer_list_page.dart';
import 'package:customer/util/api.dart';
import 'package:customer/util/dialog_box.dart';
import 'package:customer/util/format.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/responsive.dart';
import 'package:customer/util/session.dart';
import 'package:flutter/material.dart';
import 'item_info_page.dart';

class HomePage extends StatefulWidget {
  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _listKey = GlobalKey<RemoteListState>();
  Json? userInfo;
  bool _userInfoFailed = false;

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  Future<List<Json>> _loadInventory() async {
    final data = await getJsonList(getAllInventoryUrl);
    return data
        .map((e) => <String, dynamic>{
              'inven_id': e['id'],
              'farmer_id': e['farmer_id'],
              'item_id': e['item_id'],
              'item_name': e['item_name'],
              'item_description': e['item_description'],
              'farmer_name': e['farmer_name'],
              'name': e['name'],
              'final_rate_per_kg': toDouble(e['final_rate_per_kg']),
              'remaining_weight': toDouble(e['remaining_weight']),
              'weight': toDouble(e['weight']),
            })
        .toList()
      // In-stock items first.
      ..sort((a, b) => (b['remaining_weight'] > 0 ? 1 : 0)
          .compareTo(a['remaining_weight'] > 0 ? 1 : 0));
  }

  /// The backend has no "get buyer by id" route, so find this customer in
  /// the buyer list.
  Future<void> _getUserInfo() async {
    try {
      final buyers = await getJsonList(getAllCustomersUrl);
      final me = buyers.where((b) => b['id'] == widget.userId);
      if (!mounted) return;
      setState(() {
        userInfo = me.isEmpty ? null : me.first;
        _userInfoFailed = me.isEmpty;
      });
    } catch (_) {
      if (mounted) setState(() => _userInfoFailed = true);
    }
  }

  Future<void> _logout() async {
    final ok = await confirm(context, 'Are you sure you want to log out?',
        confirmLabel: 'Log out');
    if (ok && mounted) await endSession(context);
  }

  Future<void> _itemInfo(Json inventory) async {
    final ordered = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ItemInfoPage(inventory: inventory, userId: widget.userId),
      ),
    );
    // Stock changed after an order, so reload.
    if (ordered == true) _listKey.currentState?.reload();
  }

  void _open(Widget page) {
    Navigator.pop(context); // close the drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _profileCard() {
    if (userInfo == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: _userInfoFailed
              ? TextButton.icon(
                  onPressed: () {
                    setState(() => _userInfoFailed = false);
                    _getUserInfo();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Couldn't load profile"),
                )
              : const CircularProgressIndicator(),
        ),
      );
    }
    final info = userInfo!;
    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.red[100],
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundImage: AssetImage('assets/images/ajinBro.jpg'),
            ),
            const SizedBox(height: 10),
            Text(
              info['name'] ?? 'N/A',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            InfoRow(
                icon: Icons.phone,
                label: 'Phone',
                value: info['phone'] ?? 'N/A',
                color: Colors.green[700]),
            InfoRow(
                icon: Icons.email,
                label: 'Email',
                value: info['email'] ?? 'N/A',
                color: Colors.blue[700]),
            if ((info['address'] ?? '').toString().isNotEmpty)
              InfoRow(
                  icon: Icons.location_on,
                  label: 'Address',
                  value: info['address'],
                  color: Colors.orange[800]),
          ],
        ),
      ),
    );
  }

  Widget _drawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            _profileCard(),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('All Orders'),
              onTap: () => _open(const AllOrdersPage()),
            ),
            ListTile(
              leading: const Icon(Icons.agriculture),
              title: const Text('Farmers'),
              onTap: () => _open(const FarmerListPage()),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Customers'),
              onTap: () => _open(const CustomerListPage()),
            ),
            ListTile(
              leading: const Icon(Icons.payments_outlined),
              title: const Text('All Payments'),
              onTap: () => _open(const AllPaymentPage()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              textColor: Colors.red,
              iconColor: Colors.redAccent,
              title: const Text('Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(Json inventory) {
    final inStock = (inventory['remaining_weight'] as double) > 0;
    return Card(
      elevation: 4.0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () => _itemInfo(inventory),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              getImageUrl(inventory['name']),
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
            if (!inStock)
              Positioned(
                top: 8,
                left: 8,
                child: Chip(
                  label: const Text('Sold out'),
                  backgroundColor: Colors.black87,
                  labelStyle: const TextStyle(color: Colors.white),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            inventory['item_name'] ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          '${formatMoney(inventory['final_rate_per_kg'])}/kg',
                          style: const TextStyle(
                              fontSize: 14.0, color: Colors.white),
                        ),
                      ],
                    ),
                    Text(
                      '${inventory['farmer_name'] ?? ''} • '
                      '${formatKg(inventory['remaining_weight'])} left',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(fontSize: 12.0, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        elevation: 10,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => _listKey.currentState?.reload(),
          ),
        ],
      ),
      drawer: _drawer(),
      body: RemoteList(
        key: _listKey,
        load: _loadInventory,
        gridAspectRatio: 1.1,
        itemWidth: 260,
        emptyIcon: Icons.shopping_basket_outlined,
        emptyMessage: 'No produce is available right now.',
        searchHint: 'Search produce or farmer',
        matches: (item, q) =>
            '${item['item_name']} ${item['farmer_name']} ${item['item_description']}'
                .toLowerCase()
                .contains(q),
        itemBuilder: (context, item) => _tile(item),
      ),
    );
  }
}
