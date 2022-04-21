import 'dart:ffi';

class Weather {
  final String name;
  final String country;
  final String description;
  final String icon;
  final double temp;
  final int humidity;
  final double speed;

  Weather(this.name, this.country, this. description, this.icon, this.temp, this.humidity, this.speed);

  factory Weather.fromJson(Map<String, dynamic> data) {
    return Weather(
        data['name'],
        data['sys']['country'],
        data['weather'][0]['description'],
        data['weather'][0]['icon'],
        data['main']['temp'] - 273.15,
        data['main']['humidity'],
        data['wind']['speed']
    );
  }
}

