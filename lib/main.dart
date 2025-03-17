import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Import SpinKit

const String apiKey = '7d5b8634b1df2e08455cef623b46dcad';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoadingScreen(),
        '/home': (context) => MyHomePage(title: 'Weather App'),
      },
    ),
  );
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[300],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Flutter Weather App',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            SpinKitWave(color: Colors.white, size: 50.0),
          ],
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String cityName = 'Hanoi'; // Default city
  String weatherInfo = '';
  List<Widget> forecastCards = [];
  bool isLoading = false;
  String errorMessage = '';

  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    cityController.text = cityName;
    getWeatherData();
  }

  Future<void> getWeatherData() async {
    setState(() {
      isLoading = true;
      errorMessage = ''; // Reset error message
    });

    await _fetchWeatherByCity(cityName);
    await _fetchForecastByCity(cityName);

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchWeatherByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['cod'] != 200) {
          setState(() {
            errorMessage = 'City not found or invalid.';
            weatherInfo = '';
          });
        } else {
          String iconCode = data['weather'][0]['icon'];
          setState(() {
            weatherInfo =
            'Current Temp: ${data['main']['temp']}°C\n'
                'Condition: ${capitalizeCondition(data['weather'][0]['description'])}\n'
                'Icon: $iconCode\n'
                'Humidity: ${data['main']['humidity']}%\n'
                'Wind Speed: ${data['wind']['speed']} m/s\n';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data from the server.';
          weatherInfo = '';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        weatherInfo = '';
      });
    }
  }

  Future<void> _fetchForecastByCity(String city) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric',
        ),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['cod'] != '200') {
          setState(() {
            errorMessage = 'City not found or invalid.';
            forecastCards = [];
          });
        } else {
          setState(() {
            forecastCards = [];
            Map<String, List<dynamic>> groupedForecast = {};
            for (var item in data['list']) {
              String date = item['dt_txt'].split(' ')[0];
              if (!groupedForecast.containsKey(date)) {
                groupedForecast[date] = [];
              }
              groupedForecast[date]?.add(item);
            }

            groupedForecast.forEach((date, items) {
              forecastCards.add(
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('MMMM d, yyyy')
                                .format(DateFormat('yyyy-MM-dd').parse(date)),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children: items.map((item) {
                              String description = capitalizeCondition(
                                  item['weather'][0]['description']);
                              String temp = item['main']['temp'].toString();
                              String time = item['dt_txt'].split(' ')[1];
                              return Column(
                                children: [
                                  Text(time, style: const TextStyle(fontSize: 12)),
                                  Text('$temp°C', style: const TextStyle(fontSize: 14)),
                                  Text(description, style: const TextStyle(fontSize: 12)),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch forecast data from the server.';
          forecastCards = [];
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        forecastCards = [];
      });
    }
  }

  String capitalizeCondition(String condition) {
    return condition
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              onChanged: (value) => cityName = value,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: getWeatherData,
                icon:  isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.search),
                label: Text('Get Weather'),
              ),
            ),
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red)),
            if (weatherInfo.isNotEmpty) ...[
              Container(
                height: 250,
                child: Card(
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Image.network(
                          'https://openweathermap.org/img/wn/${weatherInfo.split('\n')[2].split(':')[1].trim()}@2x.png',
                          width: 100,
                          height: 100,
                        ),
                        Text(weatherInfo.split('\n')[1], style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ),
              ...forecastCards,
            ],
          ],
        ),
      ),
    );
  }
}