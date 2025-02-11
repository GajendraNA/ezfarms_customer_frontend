import 'package:customer/util/bottom_navigation_bar_page.dart';
import 'package:customer/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData(
    scaffoldBackgroundColor: Colors.red[50], 
    
    appBarTheme: AppBarTheme(
      color: Colors.red[700], 
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.black, 
        fontSize: 20, 
        fontWeight: FontWeight.bold,
      ), 
      iconTheme: IconThemeData(
        color: Colors.black, 
      ),
    ),),
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => AuthCheck(),
        '/login': (context) => LoginPage(),
        '/home': (context) => BottomNavigationBarPage(userId: 0), // Placeholder userId, will be set later
      },
    );
  }
}

class AuthCheck extends StatefulWidget {
  @override
  _AuthCheckState createState() => _AuthCheckState();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('loggedUserID');
    setState(() {
      _isLoading = false;
      _userId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_userId != null) {
      return BottomNavigationBarPage(userId: _userId!); // Pass the userId if logged in
    } else {
      return LoginPage();
    }
  }
}
