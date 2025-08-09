import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import '../models/park.dart';

class LocationService {
  static const String _apiKey = 'AIzaSyABY9ditfCBGl3x9iiNH9SFjpEqw6s2iT8';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  // Check if location services are enabled
  static Future<bool> _isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check and request location permissions
  static Future<LocationPermission> _checkPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  // Get current position with error handling
  static Future<Position?> getCurrentPosition() async {
    try {
      if (!await _isLocationServiceEnabled()) {
        return null;
      }

      LocationPermission permission = await _checkPermissions();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error getting position: $e');
      return null;
    }
  }

  // Get address from latitude and longitude
  static Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return [
          if (place.street != null) place.street,
          if (place.locality != null) place.locality,
          if (place.administrativeArea != null) place.administrativeArea,
        ].where((part) => part != null).join(', ');
      }
      return 'Unknown location';
    } catch (e) {
      print('Error getting address: $e');
      return 'Unknown location';
    }
  }

  // Get the 3 closest parks to user's location
  static Future<List<Park>> getNearbyParks(double lat, double lng) async {
    try {
      final url = '$_baseUrl/nearbysearch/json?location=$lat,$lng&radius=1500&type=park&key=$_apiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = List<Map<String, dynamic>>.from(data['results']);

        // Create list of parks with distances
        List<Park> parks = results.map((place) {
          final loc = place['geometry']['location'];
          final distance = Geolocator.distanceBetween(
              lat, lng, loc['lat'], loc['lng']
          );
          return Park.fromGoogleMaps(place).copyWith(
            distance: distance,
            latitude: loc['lat'],
            longitude: loc['lng'],
          );
        }).toList();

        // Sort by distance and take top 3
        parks.sort((a, b) => a.distance.compareTo(b.distance));
        return parks.take(3).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching nearby parks: $e');
      return [];
    }
  }

  // Get simple address (just locality)
  static Future<String> getSimpleAddress(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      final place = placemarks.first;
      return place.locality ?? place.subLocality ?? 'Current location';
    } catch (e) {
      return 'Current location';
    }
  }
}