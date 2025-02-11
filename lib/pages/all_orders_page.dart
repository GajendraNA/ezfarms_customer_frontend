import 'dart:convert';
import 'package:customer/util/ipfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:ez_farms_/ipfile.dart';

class AllOrdersPage extends StatefulWidget {
  const AllOrdersPage({
    super.key,
  });

  @override
  State<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends State<AllOrdersPage> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    // Fetch mission data when the screen is opened
    getAllMissions();
  }

  Future<void> getAllMissions() async {
    try {
      final response = await http.get(Uri.parse(getAllOrdersUrl));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data
        dynamic data = json.decode(response.body);
        print(data);

        List<dynamic> dataList = data as List<dynamic>;

        List<Map<String, dynamic>> order = [];

        // Iterate through each element in dataList
        for (var element in dataList) {
          Map<String, dynamic> resultMap = {
            'inv_name': element['inventory_name'],
            'item': element['item_name'],
            'customer': element['buyer_name'],
            'farmer': element['farmer_name'],
            'weight': element['weight'],
            'ord_date': element['ordered_date'],
            'del_date': element['est_delivery_date'],
            'order_amount': element['order_amount'],
            'status': element['status'],
            'item_rate': element['item_rate'],
            'picture': element['picture'],
          };

          print(resultMap);
          orders.add(resultMap);
        }
        setState(() {
          order = List.from(orders);
        });
      } else {
        throw Exception('Failed to load missions');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ALL ORDERS'),
        backgroundColor: Colors.red,
        shadowColor: Colors.black,
        elevation: 10,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // _buildHeading('Exsisting Orders'),
                  SizedBox(height: 10.0),
                  _buildMissionList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMissionList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(), // Disable outer scrolling
            itemCount: orders.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildMissionCard(orders[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> missionData) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Network Image at the top taking half the screen height
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0),
              topRight: Radius.circular(15.0),
            ),
            child: Image.network(
              getImageUrl(missionData['picture']),
              width: double.infinity,
              height: MediaQuery.of(context).size.height *
                  0.4, // 40% of screen height
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image,
                    size: 80.0, color: Colors.grey);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          // Information section with smaller text size and reduced spacing
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_bag,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Item:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      missionData['item'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced height
                Row(
                  children: [
                    const Icon(
                      Icons.scale,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Weight:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      missionData['weight'].toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced height
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Cost Per Kg:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      '₹${missionData['item_rate']?.toString() ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced height
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Total Cost:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      '₹${missionData['order_amount']?.toString() ?? 'N/A'}',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced height
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Farmer:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      missionData['farmer'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.person,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Customer:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      missionData['customer'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced height
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Ordered Date:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      missionData['ord_date'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced height
                Row(
                  children: [
                    const Icon(
                      Icons.delivery_dining,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Delivery Date:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      missionData['del_date'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced height
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blueAccent,
                      size: 15,
                    ),
                    const SizedBox(width: 8), // Reduced width
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 16, // Smaller font size
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduced width
                    Text(
                      missionData['status'] ?? 'N/A',
                      style: const TextStyle(fontSize: 16), // Smaller font size
                    ),
                    const SizedBox(height: 6), // Reduced height
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
