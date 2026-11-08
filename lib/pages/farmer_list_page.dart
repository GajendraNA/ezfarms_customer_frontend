import 'package:customer/pages/people_list_page.dart';
import 'package:customer/util/ipfile.dart';
import 'package:flutter/material.dart';

class FarmerListPage extends StatelessWidget {
  const FarmerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PeopleListPage(
      title: 'FARMERS',
      url: getAllFarmersUrl,
      icon: Icons.agriculture,
    );
  }
}
