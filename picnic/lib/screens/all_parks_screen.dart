import 'package:flutter/material.dart';
import '../models/park.dart';

class AllParksScreen extends StatelessWidget {
  const AllParksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Park> parks = ModalRoute.of(context)!.settings.arguments as List<Park>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Parks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: parks.length,
        itemBuilder: (context, index) {
          final park = parks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.park, color: Colors.green),
              title: Text(park.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(park.address),
              trailing: park.rating != null
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  Text(park.rating!.toStringAsFixed(1)),
                ],
              )
                  : null,
              onTap: () {
                // Navigate to park details
              },
            ),
          );
        },
      ),
    );
  }
}