import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'dart:core';
import 'package:weather/models/weather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Weather weather;
  TimeOfDay currentTime = TimeOfDay.now();
  String location = 'loading...';
  String status = 'loading';
  String idIcon = '10d';
  double temperature = 0.0;
  int humidity = 0;
  double wind = 0;
  double lat = 21.0245;
  double lon = 105.8412;

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  void _getUserLocation() async {
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();
    setState(() {
      _userLocation = _locationData;
    });
  }

  void _incrementCounter() {
    getData();
    setState(() {
      currentTime = TimeOfDay.now();
    });
  }

  void getData() async {
    _getUserLocation();
    final request =
        "https://api.openweathermap.org/data/2.5/weather?lat=${_userLocation?.latitude}&lon=${_userLocation?.longitude}&appid=bc12083e70d2d22298c2df1cec7101d9";
    http.Response response = await http.get(Uri.parse(request));
    if(response.statusCode == 200) {
      weather = Weather.fromJson(jsonDecode(response.body));
      setState(() {
        location = weather.name + ', ' + weather.country;
        status = weather.description;
        temperature = weather.temp;
        humidity = weather.humidity;
        wind = weather.speed;
        idIcon = weather.icon;
      });
    } else {
      throw Exception('Unable to fetch weather from the REST API');
    }
  }

  @override
  Widget build(BuildContext context) {
    if(location == 'loading...') {
      getData();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(50.0),
          decoration: BoxDecoration(color: Colors.lightBlue[50]),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(location,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 36,
                      fontWeight: FontWeight.w600)),
              Text('Last updated at ' + currentTime.format(context),
                  style: Theme.of(context).textTheme.headline5),
              SizedBox(
                child: Column(
                  children: [
                    Image.network(
                        'http://openweathermap.org/img/wn/$idIcon@2x.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill),
                    Text(status,
                        style: TextStyle(
                            color: Colors.blueGrey[400],
                            fontSize: 24,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 50)),
              Row(
                children: [
                  Image.asset('assets/celsius.png', width: 80, height: 36),
                  Text('Temperature: ${temperature.roundToDouble()} °C',
                      style: TextStyle(
                          color: Colors.orange[600],
                          fontSize: 20,
                          fontWeight: FontWeight.w500))
                ],
              ),
              Row(
                children: [
                  Image.asset('assets/humidity.png', width: 80, height: 36),
                  Text('Humidity: $humidity %',
                      style: TextStyle(
                          color: Colors.blue[600],
                          fontSize: 20,
                          fontWeight: FontWeight.w500))
                ],
              ),
              Row(
                children: [
                  Image.asset('assets/wind.png', width: 80, height: 36),
                  Text('Wind: $wind m/s',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 20,
                          fontWeight: FontWeight.w500))
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
