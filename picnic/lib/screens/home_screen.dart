import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/park.dart';
import '../models/weather.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';

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

  Weather? currentWeather;
  String? weatherError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadLocationData());
  }

  Future<void> _loadLocationData() async {
    setState(() {
      isLoading = true;
      locationStatus = 'Loading location...';
      weatherError = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();

      if (!mounted) return;

      if (position == null) {
        setState(() {
          locationStatus = 'Location access denied';
          isLoading = false;
          currentWeather = null;
          weatherError = 'Location unavailable';
        });
        return;
      }

      final lat = position.latitude;
      final lon = position.longitude;

      final results = await Future.wait([
        LocationService.getSimpleAddress(lat, lon),
        LocationService.getNearbyParks(lat, lon),
        WeatherService.getCurrentWeather(lat, lon),
      ]);

      setState(() {
        locationStatus = results[0] as String;
        nearbyParks = (results[1] as List<Park>);
        currentWeather = results[2] as Weather?;
        weatherError = currentWeather == null ? 'Failed to fetch weather' : null;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        locationStatus = 'Location unavailable';
        isLoading = false;
        currentWeather = null;
        weatherError = 'Failed to load weather.';
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
      body: RefreshIndicator(
        onRefresh: _loadLocationData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLocationBanner(),
              const SizedBox(height: 12),
              _buildWeatherCard(),

              const SizedBox(height: 16),
              const Divider(thickness: 1),
              const SizedBox(height: 20),

              _buildNavigationRow(),
              const Divider(thickness: 1),
              const SizedBox(height: 20),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildNearbyParksSection(),
              const Divider(thickness: 1),
              const SizedBox(height: 20),

              _buildPicnicSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationBanner() {
    return Card(
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.my_location, color: Colors.green),
        title: const Text('Your Location'),
        subtitle: Text(locationStatus),
        trailing: IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          onPressed: _loadLocationData,
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 12),
              Text('Fetching weather...'),
            ],
          ),
        ),
      );
    }

    if (currentWeather == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off, color: Colors.grey),
          title: const Text('Weather unavailable'),
          subtitle: Text(weatherError ?? 'Try pulling to refresh.'),
          trailing: IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLocationData,
          ),
        ),
      );
    }

    final w = currentWeather!;
    return Card(
      child: ListTile(
        leading: (w.iconUrl != null)
            ? Image.network(w.iconUrl!, width: 48, height: 48)
            : const Icon(Icons.wb_sunny, color: Colors.orange, size: 36),
        title: Text('${w.tempC.toStringAsFixed(0)}°C  •  ${w.description}'),
        subtitle: Text('H ${w.tempMaxC.toStringAsFixed(0)}°  •  L ${w.tempMinC.toStringAsFixed(0)}°'),
        trailing: Text(
          w.city ?? '',
          style: const TextStyle(fontWeight: FontWeight.w600),
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
