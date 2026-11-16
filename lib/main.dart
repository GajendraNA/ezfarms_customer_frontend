import 'package:customer/util/bottom_navigation_bar_page.dart';
import 'package:customer/pages/login_page.dart';
import 'package:customer/util/ipfile.dart';
import 'package:customer/util/server_wakeup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadServerAddress();
  wakeUpServer();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        scaffoldBackgroundColor: Colors.red[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.red,
          shadowColor: Colors.black,
          elevation: 4,
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          actionsIconTheme: const IconThemeData(color: Colors.black),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'EZ Farms Customer',
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    int? userId;
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getInt('loggedUserID');
    } catch (_) {
      // Treat unreadable preferences as logged out.
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _userId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_userId != null) {
      return BottomNavigationBarPage(userId: _userId!);
    }
    return const LoginPage();
  }
}
