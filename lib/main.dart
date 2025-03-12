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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        weatherInfo =
        'Current Temp: ${data['main']['temp']}°C\nDescription: ${data['weather'][0]['description']}\nMin Temp: ${data['main']['temp_min']}°C\nMax Temp: ${data['main']['temp_max']}°C\nHumidity: ${data['main']['humidity']}%\nWind Speed: ${data['wind']['speed']} m/s';
      });
    } else {
      setState(() {
        weatherInfo = 'Failed to fetch data for city $city.';
      });
    }

    // Fetch 5-day forecast
    final forecastResponse = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric'),
    );

    if (forecastResponse.statusCode == 200) {
      var forecastData = json.decode(forecastResponse.body);
      setState(() {
        forecastInfo = '5-day forecast:\n';
        for (var i = 0; i < forecastData['list'].length; i++) {
          String date = forecastData['list'][i]['dt_txt'];
          String description = forecastData['list'][i]['weather'][0]['description'];
          double temp = forecastData['list'][i]['main']['temp'];
          String formattedDate = date.split(' ')[0]; // Just the date
          forecastInfo += '$formattedDate: $description, Temp: ${temp}°C\n';
        }
      });
    } else {
      setState(() {
        forecastInfo = 'Failed to fetch forecast for city $city.';
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
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
              icon: isLoading
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
                          const Icon(Icons.thermostat, size: 40, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('Temperature: ${weatherInfo.split('\n')[0]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.water_drop, size: 40, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('Humidity: ${weatherInfo.split('\n')[4]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.wind_power, size: 40, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('Wind Speed: ${weatherInfo.split('\n')[5]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward, size: 40, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('Min Temp: ${weatherInfo.split('\n')[2]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, size: 40, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('Max Temp: ${weatherInfo.split('\n')[3]}'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('5-day forecast', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (var line in forecastInfo.split('\n'))
                if (line.isNotEmpty)
                  Card(
                    elevation: 5,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          const Icon(Icons.date_range, size: 30, color: Colors.blue),
                          const SizedBox(width: 10),
                          Expanded(child: Text(line)),
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
