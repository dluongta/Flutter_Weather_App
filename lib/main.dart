import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// Replace with your OpenWeatherMap API key
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
  String cityName = '';
  String weatherInfo = '';
  String forecastInfo = '';
  bool isLoading = false;
  bool hasWeatherData = false;

  final TextEditingController cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Fetch weather data based on city or location
  Future<void> getWeatherData() async {
    setState(() {
      isLoading = true;
    });

    if (cityName.isEmpty) {
      // Get location if no city name is entered
      Position position = await _determinePosition();
      double latitude = position.latitude;
      double longitude = position.longitude;
      await _fetchWeatherByCoordinates(latitude, longitude);
    } else {
      await _fetchWeatherByCity(cityName);
    }
  }

  // Get weather by city name
  Future<void> _fetchWeatherByCity(String city) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        weatherInfo =
        'Current Temp: ${data['list'][0]['main']['temp']}°C\nDescription: ${data['list'][0]['weather'][0]['description']}\nMin Temp: ${data['list'][0]['main']['temp_min']}°C\nMax Temp: ${data['list'][0]['main']['temp_max']}°C\nHumidity: ${data['list'][0]['main']['humidity']}%\nWind Speed: ${data['list'][0]['wind']['speed']} m/s';
        forecastInfo = '5-day forecast:\n';
        for (var i = 0; i < data['list'].length; i++) {
          String date = data['list'][i]['dt_txt'];
          String description = data['list'][i]['weather'][0]['description'];
          double temp = data['list'][i]['main']['temp'];
          String formattedDate = date.split(' ')[0]; // chỉ lấy ngày
          forecastInfo += '$formattedDate: $description, Temp: ${temp}°C\n';
        }
      });
      setState(() {
        hasWeatherData = true;
      });
    } else {
      setState(() {
        weatherInfo = 'Failed to fetch data for city $city.';
        hasWeatherData = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Get weather by coordinates
  Future<void> _fetchWeatherByCoordinates(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        weatherInfo =
        'Current Temp: ${data['list'][0]['main']['temp']}°C\nDescription: ${data['list'][0]['weather'][0]['description']}\nMin Temp: ${data['list'][0]['main']['temp_min']}°C\nMax Temp: ${data['list'][0]['main']['temp_max']}°C\nHumidity: ${data['list'][0]['main']['humidity']}%\nWind Speed: ${data['list'][0]['wind']['speed']} m/s';
        forecastInfo = '5-day forecast:\n';
        for (var i = 0; i < data['list'].length; i++) {
          String date = data['list'][i]['dt_txt'];
          String description = data['list'][i]['weather'][0]['description'];
          double temp = data['list'][i]['main']['temp'];
          String formattedDate = date.split(' ')[0]; // chỉ lấy ngày
          forecastInfo += '$formattedDate: $description, Temp: ${temp}°C\n';
        }
      });
      setState(() {
        hasWeatherData = true;
      });
    } else {
      setState(() {
        weatherInfo = 'Failed to fetch data for location.';
        hasWeatherData = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  // Determine current position (location)
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
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
            if (hasWeatherData)
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Enter city name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),  // Icon for the text field
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
                  : const Icon(Icons.search), // Search icon
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
                          const Icon(Icons.thermostat, size: 40, color: Colors.blue), // Nhiệt độ
                          const SizedBox(width: 10),
                          Text('Temperature: ${weatherInfo.split('\n')[0]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.water_drop, size: 40, color: Colors.blue), // Độ ẩm
                          const SizedBox(width: 10),
                          Text('Humidity: ${weatherInfo.split('\n')[4]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.wind_power, size: 40, color: Colors.blue), // Tốc độ gió
                          const SizedBox(width: 10),
                          Text('Wind Speed: ${weatherInfo.split('\n')[5]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward, size: 40, color: Colors.blue), // Nhiệt độ thấp nhất
                          const SizedBox(width: 10),
                          Text('Min Temp: ${weatherInfo.split('\n')[2]}'),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, size: 40, color: Colors.blue), // Nhiệt độ cao nhất
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
                          const Icon(Icons.date_range, size: 30, color: Colors.blue), // Ngày
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
