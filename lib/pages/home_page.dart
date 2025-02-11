import 'dart:convert';

import 'package:customer/pages/all_orders_page.dart';
import 'package:customer/pages/all_payment_page.dart';
import 'package:customer/pages/customer_list_page.dart';
import 'package:customer/pages/farmer_list_page.dart';
import 'package:customer/pages/login_page.dart';
import 'package:customer/util/dialog_box.dart';
import 'package:customer/util/ipfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'item_info_page.dart'; // Import your ItemInfoPage
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final int userId;
  const HomePage({
    super.key,
    required this.userId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> inventories = [];
  Map<String, dynamic>? userInfo;

  Future<void> getAllInventory() async {
    try {
      final url = Uri.parse(getAllInventoryUrl);

      // Perform the GET request
      final response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        List<dynamic> dataList = data as List<dynamic>;
        List<Map<String, dynamic>> inventoryList = [];

        for (var element in dataList) {
          Map<String, dynamic> resultMap = {
            'inven_id': element['id'],
            'farmer_id': element['farmer_id'],
            'item_id': element['item_id'],
            'item_name': element['item_name'],
            'item_description': element['item_description'],
            'farmer_name': element['farmer_name'],
            'name': element['name'],
            'final_rate_per_kg': element['final_rate_per_kg'],
            'remaining_weight': element['remaining_weight'],
            'weight': element['weight'],
          };
          inventoryList.add(resultMap);
        }

        setState(() {
          inventories = inventoryList;
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> getUserInfo() async {
    try {
      final url = Uri.parse('${apiUrl('farmer')}/${widget.userId}');

      // Perform the GET request
      final response = await http.get(url);
      print('Response1 status: ${response.statusCode}');
      print('Response1 body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse the JSON response to get a single user object
        Map<String, dynamic> data = json.decode(response.body);

        // Extract the user information
        setState(() {
          userInfo = {
            "name": data['name'],
            "phone": data['phone'],
            "email": data['email'],
            "address": data['address'],
          };
        });
      } else {
        throw Exception('Failed to load Farmer Info');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getAllInventory();
    getUserInfo();
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedUserID');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }


  void _cancel() {
    Navigator.of(context).pop();
  }

  void _loggingOut() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          text: "Are You sure to logout",
          onSave: _logout,
          onCancel: _cancel,
        );
      },
    );
  }

  void _itemInfo(Map<String, dynamic> inventory) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemInfoPage(
          inventory: inventory,
          userId: widget.userId,
        ),
      ),
    );
    if (result == true) {
      // Refresh the data on this page
      getAllInventory(); // Call the method to reload item info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOME'),
        backgroundColor: Colors.red,
        shadowColor: Colors.black,
        elevation: 10,
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.inventory),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => AllInventoriesPage()),
        //       );
        //     },
        //   ),
        // ],
      ),
      drawer: Drawer(
        width: 200,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            userInfo != null
                ? Card(
                    margin: const EdgeInsets.all(10),
                    color: Colors.red[100],
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          // Profile picture
                          CircleAvatar(
                            radius: 80,
                            backgroundImage:
                                AssetImage('assets/images/ajinBro.jpg'),
                          ),
                          const SizedBox(width: 20),
                          // Contact details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  userInfo!['name'] ?? 'N/A',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.phone, color: Colors.green),
                                  const SizedBox(width: 5),
                                  Text(userInfo!['phone'] ?? 'N/A'),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.email, color: Colors.blue),
                                  const SizedBox(width: 5),
                                  Text(
                                    userInfo!['email'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize:
                                          12.0, // Set the desired text size here
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child:
                        CircularProgressIndicator()), // Show a loading indicator while userInfo is being fetched
            // ListTile(
            //   leading: Icon(Icons.inventory_2),
            //   title: Text("All Inventories"),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => AllInventoriesPage(),
            //       ),
            //     );
            //   },
            // ),
            ListTile(
              leading: Icon(Icons.border_outer_rounded),
              title: Text("All Orders"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllOrdersPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Farmers"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmerListPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Customers"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerListPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.payment_outlined),
              title: Text("Payments"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllPaymentPage(),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.logout),
              textColor: Colors.red,
              iconColor: Colors.redAccent,
              title: Text(
                "Log Out",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                _loggingOut();
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: inventories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (context, index) {
            final inventory = inventories[index];
            return GestureDetector(
              onTap: () {
                _itemInfo(inventory);
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: inventory != null && inventory?['name'] != null
                          ? Image.network(
                            getImageUrl(inventory?['name']),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    size: 80.0, color: Colors.grey);
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                            )
                          : Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.white, // or use a placeholder image
                              child: Center(
                                child: Text(
                                  'Loading the image',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          ),
                          color: Colors.black.withOpacity(0.6),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              inventory['item_name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '₹ ${inventory['final_rate_per_kg'] ?? 'Unknown'}',
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
