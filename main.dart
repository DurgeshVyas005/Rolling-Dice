import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController _controller = TextEditingController();
  String cityName = "";
  String condition = "";
  String iconUrl = "";
  String temperature = "";
  bool isLoading = false;

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
      cityName = "";
      condition = "";
      iconUrl = "";
      temperature = "";
    });

    String apiKey = "4dd00d81fc8f460391360455252108";
    String url =
        "http://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city&aqi=yes";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          cityName = data['location']['name'];
          condition = data['current']['condition']['text'];
          iconUrl = "https:${data['current']['condition']['icon']}";
          temperature = "${data['current']['temp_c']} °C";
        });
      } else {
        setState(() {
          condition = "Error: Unable to fetch data";
        });
      }
    } catch (e) {
      setState(() {
        condition = "Error: $e";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter City",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String city = _controller.text.trim();
                if (city.isNotEmpty) {
                  fetchWeather(city);
                }
              },
              child: const Text("Get Weather"),
            ),
            const SizedBox(height: 30),
            if (isLoading) const CircularProgressIndicator(),
            if (!isLoading && cityName.isNotEmpty)
              Column(
                children: [
                  Text(
                    cityName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (iconUrl.isNotEmpty)
                    Image.network(
                      iconUrl,
                      width: 80,
                      height: 80,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    condition,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Temperature: $temperature",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
