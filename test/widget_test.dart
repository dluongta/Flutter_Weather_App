import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_app/main.dart'; // Make sure the import points to your app's main.dart

void main() {
  testWidgets('Weather data is fetched and displayed after entering city name and clicking Get Weather', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      title: 'Flutter Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => LoadingScreen(),
        '/home': (context) => MyHomePage(title: 'Weather App'),
      },
    ));

    // Find the text field and type a city name (e.g., 'Hanoi').
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Hanoi');

    // Find the 'Get Weather' button and tap it.
    final getWeatherButton = find.text('Get Weather');
    await tester.tap(getWeatherButton);

    // Trigger a frame to simulate waiting for the data to load.
    await tester.pumpAndSettle();

    // Verify that the weather information is displayed after the button is pressed.
    expect(find.textContaining('Current Temp:'), findsOneWidget);
    expect(find.textContaining('Condition:'), findsOneWidget);
    expect(find.textContaining('Humidity:'), findsOneWidget);
    expect(find.textContaining('Wind Speed:'), findsOneWidget);

    // Optionally, you can check if the error message is not shown when the city is valid.
    expect(find.text('City not found or invalid.'), findsNothing);
  });
}
