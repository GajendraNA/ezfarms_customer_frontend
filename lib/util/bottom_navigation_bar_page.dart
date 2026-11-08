import 'package:customer/pages/home_page.dart';
import 'package:customer/pages/orders_page.dart';
import 'package:customer/pages/payment_page.dart';
import 'package:customer/util/responsive.dart';
import 'package:flutter/material.dart';

/// The main app shell: a bottom bar on phones and a side rail on wider
/// screens (tablets, landscape, desktop, web).
class BottomNavigationBarPage extends StatefulWidget {
  final int userId;

  const BottomNavigationBarPage({super.key, required this.userId});

  @override
  State<BottomNavigationBarPage> createState() =>
      _BottomNavigationBarPageState();
}

class _Destination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _Destination(this.icon, this.selectedIcon, this.label);
}

const _destinations = [
  _Destination(Icons.home_outlined, Icons.home, 'Home'),
  _Destination(Icons.history, Icons.history, 'My Orders'),
  _Destination(Icons.payment_outlined, Icons.payment, 'Payments'),
];

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  int _selectedIndex = 0;

  Widget _page(int index) {
    // Pages are rebuilt on each switch so Orders and Payments always show
    // fresh data (e.g. right after placing an order).
    switch (index) {
      case 1:
        return OrdersPage(userId: widget.userId);
      case 2:
        return PaymentPage(userId: widget.userId);
      default:
        return HomePage(userId: widget.userId);
    }
  }

  void _select(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final page = KeyedSubtree(
      key: ValueKey(_selectedIndex),
      child: _page(_selectedIndex),
    );

    if (isWide(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: Colors.red[50],
              selectedIndex: _selectedIndex,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              indicatorColor: Colors.red[200],
              selectedIconTheme: IconThemeData(color: Colors.red[800]),
              unselectedIconTheme: IconThemeData(color: Colors.red[400]),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: page),
          ],
        ),
      );
    }

    return Scaffold(
      body: page,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.red[50],
        indicatorColor: Colors.red[200],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _select,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon, color: Colors.red[400]),
              selectedIcon: Icon(d.selectedIcon, color: Colors.red[800]),
              label: d.label,
            ),
        ],
      ),
    );
  }
}
