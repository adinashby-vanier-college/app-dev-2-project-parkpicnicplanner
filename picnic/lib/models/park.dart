class Park {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distance; // in meters
  final double? rating;
  final List<String> features;

  Park({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.rating,
    this.features = const [],
  });

  factory Park.fromGoogleMaps(Map<String, dynamic> data) {
    final location = data['geometry']['location'];
    return Park(
      id: data['place_id'],
      name: data['name'],
      address: data['vicinity'] ?? 'Unknown address',
      latitude: location['lat'].toDouble(),
      longitude: location['lng'].toDouble(),
      distance: 0, // Will be calculated later
      rating: data['rating']?.toDouble(),
    );
  }

  String get distanceString {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }
  Park copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? distance,
    double? rating,
    List<String>? features,
  }) {
    return Park(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      rating: rating ?? this.rating,
      features: features ?? this.features,
    );
  }
}
