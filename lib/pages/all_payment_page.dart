import 'dart:convert';


import 'package:customer/util/ipfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:ez_farms_/ipfile.dart';

class AllPaymentPage extends StatefulWidget {
  const AllPaymentPage({super.key,});

  @override
  State<AllPaymentPage> createState() => _AllPaymentPageState();
}

class _AllPaymentPageState extends State<AllPaymentPage> {
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    // Fetch mission data when the screen is opened
    getAllMissions();
  }

  Future<void> getAllMissions() async {
    try {
      final url = Uri.parse(getAllPayments);

      // Perform the GET request
      final response = await http.get(url);
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
            'customer': element['buyerName'],
            'farmer': element['farmerName'],
            'order_amount': element['order_amount'],
            'payment_date': element['payment_date'],
            'method': element['method'],
            'final_amount': element['final_amount'],
            'payment_amount': element['payment_amount'],
          };

          print(resultMap);
          orders.add(resultMap);
        }
        setState(() {
          order = List.from(orders);
        });
      } else {
        // If the server did not return a 200 OK response, throw an exception.
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
        title: Text('ALL PAYMENTS'),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, ),
                  const SizedBox(width: 8),
                  const Text(
                    'Customer:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    missionData['customer'] ?? 'N/A',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.agriculture, ),
                  const SizedBox(width: 8),
                  const Text(
                    'Farmer:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    missionData['farmer'] ?? 'N/A',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.attach_money, ),
                  const SizedBox(width: 8),
                  const Text(
                    'Order Amount:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${missionData['order_amount']?.toString() ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today, ),
                  const SizedBox(width: 8),
                  const Text(
                    'Payment Date:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    missionData['payment_date'] ?? 'N/A',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.payment, ),
                  const SizedBox(width: 8),
                  const Text(
                    'Payment Method:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    missionData['method'] ?? 'N/A',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.money, ),
                  const SizedBox(width: 8),
                  const Text(
                    'Final Amount:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${missionData['final_amount']?.toString() ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, ),
                  const SizedBox(width: 8),
                  const Text(
                    'Payment Amount:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₹${missionData['payment_amount']?.toString() ?? 'N/A'}',
                    style: const TextStyle(fontSize: 16),
                  ),
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