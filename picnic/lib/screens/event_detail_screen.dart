import 'package:flutter/material.dart';
import 'package:picnic/screens/profile_screen.dart';
import '../models/user.dart';
import '../services/location_service.dart';

class EventDetailScreen extends StatefulWidget {
  final List<User> attendees;

  const EventDetailScreen({super.key, required this.attendees});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  String? eventLocation;
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _loadEventLocation();
  }

  Future<void> _loadEventLocation() async {
    // Simulate getting event location (in a real app, this would come from your backend)
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      final address = await LocationService.getAddressFromLatLng(
        position.latitude + 0.01, // Offset slightly for demo
        position.longitude + 0.01,
      );
      setState(() {
        eventLocation = address;
        isLoadingLocation = false;
      });
    } else {
      setState(() {
        eventLocation = 'Central Park, New York'; // Fallback
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community Picnic',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Hosted by Jane Smith',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 10),
                isLoadingLocation
                    ? const CircularProgressIndicator()
                    : Expanded(
                  child: Text(
                    eventLocation ?? 'Location not available',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.wb_sunny),
                const SizedBox(width: 10),
                const Text('Sunny, 75°F'),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Attendees',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: widget.attendees.length,
                itemBuilder: (context, index) {
                  final user = widget.attendees[index];
                  return ListTile(
                    leading: user.isPrivate
                        ? const CircleAvatar(child: Icon(Icons.lock))
                        : CircleAvatar(
                      child: Text(user.name.substring(0, 2).toUpperCase()),
                    ),
                    title: Text(
                      user.isPrivate ? 'Private Attendee' : user.name,
                      style: TextStyle(
                        fontStyle: user.isPrivate ? FontStyle.italic : null,
                      ),
                    ),
                    onTap: user.isPrivate
                        ? null
                        : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(user: user),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}