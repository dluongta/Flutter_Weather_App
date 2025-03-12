import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiKey = '7d5b8634b1df2e08455cef623b46dcad';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Weather App'),
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
  String forecastInfo = '';
  bool isLoading = false;
  bool hasWeatherData = false;

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
    });

    await _fetchWeatherByCity(cityName);
  }

  Future<void> _fetchWeatherByCity(String city) async {
    final response = await http.get(
      Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        weatherInfo =
            'Current Temp: ${data['main']['temp']}°C\n'
            'Condition: ${data['weather'][0]['main']}\n'
            'Humidity: ${data['main']['humidity']}%\n'
            'Wind Speed: ${data['wind']['speed']} m/s\n'
            'Min Temp: ${data['main']['temp_min']}°C\n'
            'Max Temp: ${data['main']['temp_max']}°C\n';
      });
    } else {
      setState(() {
        weatherInfo = 'Failed to fetch data for city $city.';
      });
    }

    setState(() {
      isLoading = false;
      hasWeatherData = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              onChanged: (value) {
                setState(() {
                  cityName = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: getWeatherData,
              icon:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.search),
              label: const Text('Get Weather'),
            ),
            const SizedBox(height: 20),
            if (weatherInfo.isNotEmpty) ...[
              Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text('${weatherInfo.split('\n')[0]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.sunny,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text('${weatherInfo.split('\n')[1]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text('${weatherInfo.split('\n')[2]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.wind_power,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text('${weatherInfo.split('\n')[3]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text('${weatherInfo.split('\n')[4]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_upward,
                            size: 40,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 10),
                          Text('${weatherInfo.split('\n')[5]}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
