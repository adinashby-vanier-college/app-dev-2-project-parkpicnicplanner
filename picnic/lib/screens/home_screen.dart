import 'dart:async';

import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/park.dart';
import '../services/location_service.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Park> nearbyParks = [];
  bool isLoading = true;
  String locationStatus = 'Loading location...';

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocationData());
  }

  Future<void> _loadLocationData() async {
    try {
      final position = await LocationService.getCurrentPosition();

      if (position == null) {
        setState(() => locationStatus = 'Location access denied');
        return;
      }

      Future.wait([
      LocationService.getSimpleAddress(
        position.latitude,
        position.longitude,
      ),
      LocationService.getNearbyParks(
        position.latitude,
        position.longitude,
      )]).then((results){
        switch (results){
          case [String location, List<Park> parkList]:
            setState(() {
              locationStatus = location;
              nearbyParks = parkList;
              isLoading = false;
            });
        }
      });


    } catch (e) {
      setState(() {
        locationStatus = 'Location unavailable';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Navigation Row
            _buildNavigationRow(),
            const Divider(thickness: 1),
            const SizedBox(height: 20),

            // Explore Nearby Parks section
            isLoading ? const Center(child: CircularProgressIndicator()) : _buildNearbyParksSection(),
            const Divider(thickness: 1),
            const SizedBox(height: 20),

            // Plan a Picnic section
            // isLoading ? const Center(child: CircularProgressIndicator()) :
            _buildPicnicSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavButton(Icons.edit_calendar_rounded, 'Create Picnic', () {
          Navigator.pushNamed(context, '/create');
        }),
        _buildNavButton(Icons.message, 'Messages', () {
          Navigator.pushNamed(context, '/debug', arguments: widget.user);
        }),
        _buildNavButton(Icons.person, 'Profile', () {
          Navigator.pushNamed(context, '/profile', arguments: widget.user);
        }),
      ],
    );
  }

  Widget _buildNavButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: onPressed,
        ),
        Text(label),
      ],
    );
  }

  Widget _buildNearbyParksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore Nearby Parks',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        if (nearbyParks.isEmpty)
          const Text('No parks found nearby')
        else
          Column(
            children: nearbyParks.map((park) => _buildParkCard(park)).toList(),
          ),

        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/parks', arguments: nearbyParks);
          },
          child: const Text('View All Parks'),
        ),
      ],
    );
  }

  Widget _buildParkCard(Park park) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.park, color: Colors.green, size: 36),
        title: Text(park.name),
        subtitle: Text('${park.distanceString} - ${park.address}'),
        trailing: Text(park.features.isNotEmpty ? park.features.first : ''),
      ),
    );
  }

  Widget _buildPicnicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Plan a Picnic',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildPicnicOption('Upcoming Events', Icons.event, () {
          // Navigate to events
        }),
        _buildPicnicOption('Suggested Ideas', Icons.lightbulb, () {
          // Navigate to suggestions
        }),
      ],
    );
  }

  Widget _buildPicnicOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}