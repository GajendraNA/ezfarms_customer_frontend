import 'dart:convert';
import 'package:customer/util/ipfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomerListPage extends StatefulWidget {
  const CustomerListPage({super.key});

  @override
  State<CustomerListPage> createState() => _CustomerListPageState();
}

class _CustomerListPageState extends State<CustomerListPage> {
  List<Map<String, dynamic>> farmers = [];

  Future<void> getAllFarmers() async {
    try {
      final response = await http.get(Uri.parse(getAllCustomersUrl));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the data
        dynamic data = json.decode(response.body);

        List<dynamic> dataList = data as List<dynamic>;

        List<Map<String, dynamic>> farmerList = [];

        // Iterate through each element in dataList
        for (var element in dataList) {
          Map<String, dynamic> resultMap = {
            'name': element['name'],
            'email': element['email'],
            'address': element['address'],
            'phone': element['phone']
          };
          farmerList.add(resultMap);
        }

        setState(() {
          farmers = farmerList;
        });
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        throw Exception('Failed to load customers');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch farmer data when the screen is opened
    getAllFarmers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('CUSTOMERS'),
        backgroundColor: Colors.red,
        shadowColor: Colors.black,
        elevation: 10,leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover, // Cover the entire background
          ),
        ),
        child: ListView.builder(
          itemCount: farmers.length,
          itemBuilder: (context, index) {
            final farmer = farmers[index];
            return Container(
              margin: EdgeInsets.all(10.0),
              child: ExpansionTile(
                title: Text(
                  farmer['name'] ?? 'N/A',
                  style: TextStyle(fontSize: 24, color: Colors.black,fontWeight: FontWeight.bold),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDetailText('Email', farmer['email'] ?? 'N/A'),
                          buildDetailText('Address', farmer['address'] ?? 'N/A'),
                          buildDetailText('Phone', farmer['phone'] ?? 'N/A'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


Widget buildDetailText(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$label:',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(fontSize: 16),
        maxLines: null, // Allow unlimited lines for address
        overflow: TextOverflow.visible, // Show overflow if needed
      ),
      SizedBox(height: 10),
    ],
  );
}
