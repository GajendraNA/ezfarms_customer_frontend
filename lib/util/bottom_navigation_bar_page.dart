import 'package:customer/pages/farmer_list_page.dart';
import 'package:customer/pages/home_page.dart';
import 'package:customer/pages/login_page.dart';
import 'package:customer/pages/orders_page.dart';
import 'package:customer/pages/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigationBarPage extends StatefulWidget {
  final int userId;

  const BottomNavigationBarPage({super.key, required this.userId});

  @override
  State<BottomNavigationBarPage> createState() =>
      _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(userId: widget.userId),
      OrdersPage(
        userId: widget.userId,
      ),
      PaymentPage(userId: widget.userId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
         backgroundColor: Colors.red[50], 
          selectedItemColor: Colors.red[800],
          unselectedItemColor: Colors.red[400], 
          currentIndex: _selectedIndex,
          onTap: _navigateBottomBar,
          elevation: 12, 
          selectedFontSize: 14, 
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels:
              true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(Icons.history),
            label: 'Previous Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}
