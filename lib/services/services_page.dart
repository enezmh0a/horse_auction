import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        ListTile(
          leading: Icon(Icons.storefront),
          title: Text('Auction Management'),
          subtitle: Text('Run live/online auctions'),
        ),
        ListTile(
          leading: Icon(Icons.verified),
          title: Text('Horse Registration'),
          subtitle: Text('Documents & pedigree uploads'),
        ),
        ListTile(
          leading: Icon(Icons.support_agent),
          title: Text('Seller Support'),
          subtitle: Text('Consignments & promotions'),
        ),
      ],
    );
  }
}
