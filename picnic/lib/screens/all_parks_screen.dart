import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/park.dart';
import '../services/location_service.dart';

class AllParksScreen extends StatefulWidget {
  const AllParksScreen({super.key});

  @override
  State<AllParksScreen> createState() => _AllParksScreenState();
}

class _AllParksScreenState extends State<AllParksScreen> {
  // You can optionally read this from a config/env if you prefer.
  static const String _apiKey = 'AIzaSyABY9ditfCBGl3x9iiNH9SFjpEqw6s2iT8';
  static const String _placesBase = 'https://maps.googleapis.com/maps/api/place';
  static const int _targetCount = 10;
  static const int _searchRadiusMeters = 3000; // widen radius to find enough parks

  bool _loading = true;
  String? _error;
  List<Park> _parks = [];

  @override
  void initState() {
    super.initState();
    _loadParks();
  }

  Future<void> _loadParks() async {
    setState(() {
      _loading = true;
      _error = null;
      _parks = [];
    });

    try {
      final pos = await LocationService.getCurrentPosition();
      if (!mounted) return;

      if (pos == null) {
        setState(() {
          _loading = false;
          _error =
          'Location unavailable. Please enable location services and permissions.';
        });
        return;
      }

      // Fetch enough places to select the top 10 by distance.
      final allPlaces = await _fetchNearbyParksRaw(
        pos.latitude,
        pos.longitude,
        radius: _searchRadiusMeters,
        minToCollect: _targetCount * 2, // over-fetch a bit, then trim
      );

      // Convert to Park models with distance, sort, and take top 10
      final parks = <Park>[];
      for (final place in allPlaces) {
        final geometry = place['geometry'] as Map<String, dynamic>?;
        final loc = geometry?['location'] as Map<String, dynamic>?;

        final pLat = (loc?['lat'] as num?)?.toDouble();
        final pLng = (loc?['lng'] as num?)?.toDouble();
        if (pLat == null || pLng == null) continue;

        final distance =
        Geolocator.distanceBetween(pos.latitude, pos.longitude, pLat, pLng);

        parks.add(
          Park.fromGoogleMaps(place).copyWith(
            distance: distance,
            latitude: pLat,
            longitude: pLng,
          ),
        );
      }

      parks.sort((a, b) => a.distance.compareTo(b.distance));
      final top10 = parks.take(_targetCount).toList();

      setState(() {
        _parks = top10;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load parks. $e';
      });
    }
  }

  /// Fetch raw Google Places "nearbysearch" results (parks) with optional paging,
  /// returning at least [minToCollect] items when possible.
  Future<List<Map<String, dynamic>>> _fetchNearbyParksRaw(
      double lat,
      double lng, {
        required int radius,
        int minToCollect = 20,
      }) async {
    final results = <Map<String, dynamic>>[];
    String? pageToken;
    int safetyPages = 3; // don’t loop forever; Nearby gives up to ~60 results

    do {
      final uri = Uri.parse('$_placesBase/nearbysearch/json').replace(
        queryParameters: {
          'location': '$lat,$lng',
          'radius': '$radius',
          'type': 'park',
          'key': _apiKey,
          if (pageToken != null) 'pagetoken': pageToken,
        },
      );

      final resp = await http.get(uri).timeout(const Duration(seconds: 12));
      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;
      final status = (data['status'] as String?) ?? 'UNKNOWN_ERROR';
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        // Could be INVALID_REQUEST for early pagetoken calls—retry automatically below
        if (status == 'INVALID_REQUEST' && pageToken != null) {
          // Small backoff for pagetoken readiness (Places quirk)
          await Future.delayed(const Duration(milliseconds: 800));
          continue;
        }
        final errMsg = data['error_message'] ?? status;
        throw Exception('Places API: $errMsg');
      }

      final batch = (data['results'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      results.addAll(batch);

      pageToken = data['next_page_token'] as String?;
      if (results.length >= minToCollect || pageToken == null) break;

      // According to Places API, next_page_token may take a short time to activate
      await Future.delayed(const Duration(seconds: 2));
    } while (safetyPages-- > 0);

    return results;
    // Note: "radius" affects density; increase if you consistently see < 10 results.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Parks'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadParks,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorState(message: _error!, onRetry: _loadParks)
          : _parks.isEmpty
          ? _EmptyState(onRetry: _loadParks)
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _parks.length,
        itemBuilder: (context, index) {
          final park = _parks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.park,
                  color: Colors.green, size: 28),
              title: Text(
                park.name,
                style:
                const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${_prettyDistance(park.distance)} • ${park.address}',
              ),
              trailing: park.rating != null
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star,
                      color: Colors.amber, size: 16),
                  Text(park.rating!.toStringAsFixed(1)),
                ],
              )
                  : null,
              onTap: () {
                // TODO: Navigate to park details if you have a screen
              },
            ),
          );
        },
      ),
    );
  }

  String _prettyDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 36, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.park, size: 36, color: Colors.green),
            const SizedBox(height: 12),
            const Text('No parks found nearby.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
