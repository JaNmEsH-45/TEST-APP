class Weather {
  final String cityName;
  final double temperature;
  final int humidity;
  final String description;
  final String icon;
  final double feelsLike;
  final double windSpeed;
  final int pressure;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.feelsLike,
    required this.windSpeed,
    required this.pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['location']['name'],
      temperature: json['current']['temp_c'].toDouble(),
      humidity: json['current']['humidity'],
      description: json['current']['condition']['text'],
      icon: "https:${json['current']['condition']['icon']}",
      feelsLike: json['current']['feelslike_c'].toDouble(),
      windSpeed: json['current']['wind_kph'].toDouble() / 3.6, // Convert kph to m/s
      pressure: json['current']['pressure_mb'].toInt(),
    );
  }
}