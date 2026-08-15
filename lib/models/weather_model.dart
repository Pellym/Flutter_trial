class Weather {
  final String cityName;
  final double temparature;
  final String mainCondition;

  Weather({
    required this.cityName,
    required this.temparature,
    required this.mainCondition,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      temparature: json['main']['temp'].toDouble(),
      mainCondition: json['weather'][0]['main'],
    );
  }
}