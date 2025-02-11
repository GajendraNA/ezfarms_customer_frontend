import 'dart:convert';
import 'package:customer/util/model.dart';
import 'package:customer/util/ipfile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ItemInfoPage extends StatefulWidget {
  final Map<String, dynamic> inventory;
  final int userId;

  ItemInfoPage({Key? key, required this.inventory, required this.userId})
      : super(key: key);

  @override
  State<ItemInfoPage> createState() => _ItemInfoPageState();
}

class _ItemInfoPageState extends State<ItemInfoPage> {
  double _OrderWeight = 0;
  double _order_amount = 0;
  double _discount_applied = 0;
  double _final_amount = 0;
  DateTime ordered_date = DateTime.now();

  void oneDecrement() {
    setState(() {
      if (_OrderWeight > 0) {
        _OrderWeight--;
        _updateOrderAmount();
      }
    });
  }

  void oneIncrement() {
    setState(() {
      if (_OrderWeight < (widget.inventory['remaining_weight'] as double)) {
        _OrderWeight++;
        _updateOrderAmount();
      }
    });
  }

  void _updateOrderAmount() {
    setState(() {
      _order_amount =
          _OrderWeight * (widget.inventory['final_rate_per_kg'] as double);
      _discount_applied = _order_amount * 0.05;
      _final_amount = _order_amount - _discount_applied;
    });
  }

  void _createOrd() async {
    Map<String, dynamic> newOrd = {
      'inventory_id': widget.inventory['inven_id'].toString(),
      'farmer_id': widget.inventory['farmer_id'].toString(),
      'buyer_id': widget.userId.toString(), // Replace with actual buyer ID
      'item_id': widget.inventory['item_id'].toString(),
      'weight': _OrderWeight.toString(),
      'ordered_date': ordered_date.toIso8601String(),
      'est_delivery_date':
          ordered_date.add(Duration(days: 3)).toIso8601String(),
      'order_amount': _order_amount.toString(),
      'discount_applied': _discount_applied.toString(),
      'amount_pending': _final_amount.toString(),
      'final_amount': _final_amount.toString(),
      'status': 'order placed',
    };

    print(newOrd);

    try {
      final response = await http.post(
        Uri.parse(postOrderUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(newOrd),
      );

      if (response.statusCode == 200) {
        print('Order Added');
      } else {
        throw Exception('Failed to add Order');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _updateInventory() async {
    double remainingWeight =
        (widget.inventory['remaining_weight'] as double) - _OrderWeight;
    Map<String, dynamic> updatedInventory = {
 
      'remaining_weight': remainingWeight.toString(),
    };

    print(updatedInventory);

    try {
      final response = await http.put(
        Uri.parse('$updateInventoryUrl/${widget.inventory['inven_id']}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updatedInventory),
      );

      if (response.statusCode == 200) {
        print('Inventory Updated');
      } else {
        throw Exception('Failed to update inventory      $updateInventoryUrl/${widget.inventory['inven_id']}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ITEM INFO'),
        backgroundColor: Colors.red,
        shadowColor: Colors.black,
        elevation: 10,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          getImageUrl(widget.inventory['name']),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.label, color: Colors.amber,size: 15,),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.inventory['item_name'] ?? 'Unknown',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                            Icon(Icons.label, color: Colors.amber,size: 15,),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '₹ ${widget.inventory['final_rate_per_kg']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.amber,size: 15,),
                          SizedBox(width: 10),
                          Text(
                            widget.inventory['farmer_name'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
      
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.description , color: Colors.amber,size: 15,),
                          SizedBox(width: 10),
                          Text(
                            widget.inventory['item_description'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory,
                            color: Colors.amber,size: 15,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'In inventory: ${widget.inventory['remaining_weight']}kg',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: oneDecrement,
                            child: Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: oneIncrement,
                            child: Icon(Icons.add_circle_outline,
                                color: Colors.green),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          if (_OrderWeight != 0) {
                            _createOrd();
                            _updateInventory();
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          height: 50,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Place Order ($_OrderWeight kg)',
                              style: const TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 7),
                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: Colors.amber,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '\₹ $_order_amount',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height:200),
            ],
          ),
        ),
      ),
    );
  }
}
