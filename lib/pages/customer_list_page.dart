import 'package:customer/pages/people_list_page.dart';
import 'package:customer/util/ipfile.dart';
import 'package:flutter/material.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PeopleListPage(
      title: 'CUSTOMERS',
      url: getAllCustomersUrl,
      icon: Icons.people,
    );
  }
}
