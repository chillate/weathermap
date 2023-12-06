import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather API Map',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple)
            .copyWith(secondary: Colors.deepPurple),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double latitude = 47.47; // Latitude
  late double longitude = -0.56; // Longitude
  final apiKey = 'c0bbff4a824cce23670fa594dfa7e8b1';

  String weatherDescription = '';
  double temperature = 0.0;
  String weatherIcon = 'assets/default.png';


  Map<String, String> infos = {};
  late Future<void> _fetchWeatherDataFuture;


  @override
  void initState() {
    super.initState();
    _fetchWeatherDataFuture = fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final url = 'https://api.openweathermap.org/data/2.5/onecall?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric';
    print(url);

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<String, dynamic> currentData = data['current']; 


      setState(() {
        weatherDescription = data['current']['weather'][0]['main'];
        temperature = data['current']['temp'];
        weatherIcon = getWeatherIcon(weatherDescription);

        print('Weather: $weatherDescription');
        print('Temperature: $temperature°C');

        infos = {
          'Date/Time': DateTime.fromMillisecondsSinceEpoch(currentData['dt'] * 1000).toString(),
          'Sunrise': currentData['sunrise'].toString(),
          'Sunset': currentData['sunset'].toString(),
          'Temperature': currentData['temp'].toString() + ' K',
          'Feels Like': currentData['feels_like'].toString(),
          'Pressure': currentData['pressure'].toString(),
          'Humidity': currentData['humidity'].toString(),
          'Dew Point': currentData['dew_point'].toString(),
          'UV Index': currentData['uvi'].toString(),
          'Clouds': currentData['clouds'].toString(),
          'Visibility': currentData['visibility'].toString(),
          'Wind Speed': currentData['wind_speed'].toString(),
          'Wind Degree': currentData['wind_deg'].toString(),
          'Wind Gust': currentData['wind_gust'].toString(),
        };
      });
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  String getWeatherIcon(String description) {
    if (description.toLowerCase().contains('clear')) {
      return '01d.png';
    } else if (description.toLowerCase().contains('clouds')) {
      return '03d.png';
    } else if (description.toLowerCase().contains('rain')) {
      return '09d.png';
    } else {
      return '01d.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather App'),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: FutureBuilder(
              future: _fetchWeatherDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(
                        "https://openweathermap.org/img/wn/$weatherIcon",
                        width: 50,
                        height: 50,
                      ),
                      Text('Weather: $weatherDescription'),
                      Text('Temperature: $temperature°C'),
                      Column(
                        children: infos.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Text(entry.key + ": ", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(entry.value),
                              ],
                            ),
                          );
                        }).toList(),
                      ),


                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },

            ),
          ),
      ),
    );
  }
}
