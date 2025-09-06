class Weather {
  final String? city;
  final String description;
  final double tempC;
  final double tempMinC;
  final double tempMaxC;
  final String? icon;

  Weather({
    required this.description,
    required this.tempC,
    required this.tempMinC,
    required this.tempMaxC,
    this.city,
    this.icon,
  });

  String? get iconUrl =>
      (icon == null) ? null : 'https://openweathermap.org/img/wn/$icon@2x.png';

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weatherList = (json['weather'] as List?) ?? [];
    final first = weatherList.isNotEmpty ? weatherList.first as Map<String, dynamic> : {};
    final main = (json['main'] as Map<String, dynamic>?) ?? {};
    return Weather(
      city: json['name'] as String?,
      description: (first['description'] as String? ?? 'Weather').toString(),
      tempC: (main['temp'] as num?)?.toDouble() ?? 0.0,
      tempMinC: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMaxC: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      icon: first['icon'] as String?,
    );
  }
}
