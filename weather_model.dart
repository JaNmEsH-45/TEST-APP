class Weather {
  final String cityName;
  final double temperature;
  final int humidity;
  final String description;
  final String icon;
  final double feelslike;
  final double windspeed;
  final int pressure;


  Weather({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.icon,
    required this .feelslike,
    required this .windspeed,
    required this .pressure,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['location']['name'],
      temperature: json['current']['temp_c'] * 1.0, // safe double
      humidity: json['current']['humidity'],
      description: json['current']['condition']['text'],
      icon: "https:${json['current']['condition']['icon']}",
      feelslike: json['main']['feelslike_c'].toDouble(), 
      windspeed: json['wind']['wind_kph'].toDouble(),
      pressure: json['current']['pressure']
    );
  }
}