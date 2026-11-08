import 'package:customer/util/api.dart';
import 'package:customer/util/responsive.dart';
import 'package:flutter/material.dart';

/// A searchable list of people (farmers or customers) with contact details.
class PeopleListPage extends StatelessWidget {
  final String title;
  final String url;
  final IconData icon;

  const PeopleListPage({
    super.key,
    required this.title,
    required this.url,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), elevation: 10),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: RemoteList(
          load: () async =>
              (await getJsonList(url))
                ..sort((a, b) => '${a['name']}'
                    .toLowerCase()
                    .compareTo('${b['name']}'.toLowerCase())),
          itemWidth: 340,
          emptyIcon: icon,
          emptyMessage: 'No ${title.toLowerCase()} found.',
          searchHint: 'Search by name, email or address',
          matches: (p, q) => '${p['name']} ${p['email']} ${p['address']}'
              .toLowerCase()
              .contains(q),
          itemBuilder: (context, person) => _PersonCard(person, icon),
        ),
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final Json person;
  final IconData icon;
  const _PersonCard(this.person, this.icon);

  @override
  Widget build(BuildContext context) {
    final name = (person['name'] ?? 'N/A').toString();
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white.withValues(alpha: 0.92),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
                color: Colors.red[800], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text('${person['phone'] ?? ''}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          InfoRow(
              icon: Icons.email, label: 'Email', value: person['email'] ?? 'N/A'),
          InfoRow(
              icon: Icons.phone, label: 'Phone', value: person['phone'] ?? 'N/A'),
          InfoRow(
              icon: Icons.location_on,
              label: 'Address',
              value: person['address'] ?? 'N/A'),
        ],
      ),
    );
  }
}
