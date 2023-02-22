import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;

  var lat;
  var lon;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  _determinePosition() async {
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

    position = await Geolocator.getCurrentPosition();
    lat = position!.latitude;
    lon = position!.longitude;
    print("Latitude is ${lat}");
    print("Longitude is ${lon}");
    fetchWeatherData();
  }

  fetchWeatherData() async {
    String weatherApi =
        "https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=f3b902a8b1bd6868c6286e55d217334b&units=metric";

    String forecastApi =
        "https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=f3b902a8b1bd6868c6286e55d217334b&units=metric";

    var weatherResponce = await http.get(Uri.parse(weatherApi));
    var forecastResponce = await http.get(Uri.parse(forecastApi));
    setState(() {
      weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponce.body));
      forecastMap =
          Map<String, dynamic>.from(jsonDecode(forecastResponce.body));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
          ),

          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     colors: [
          //       Color(0xff33ccff),
          //       Color(0xffff9cc),
          //     ],
          //   ),
          // ),
          child: Column(
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                "${Jiffy(DateTime.now()).format("MMMM do yyyy,\n      h:mm:ss a")}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70),
              ),
              // Text("${weatherMap!["weather"][0]["icon"]}"),
              Container(
                height: 200,
                width: 200,
                child: Image.asset(
                  "assets/sun1.png",
                  fit: BoxFit.cover,
                ),
              ),
              Text(
                "${weatherMap!["name"]}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70),
              ),
              Text(
                " C° : ${weatherMap!["main"]["temp"]} ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70),
              ),
              Text(
                " Feels_like : ${weatherMap!["main"]["feels_like"]} ",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70),
              ),
              Text(
                "${weatherMap!["weather"][0]["main"]}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70),
              ),
              Text(
                "Sunrise ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunrise"] * 1000)).format("h:mm:a")}:\n Sunset ${Jiffy(DateTime.fromMillisecondsSinceEpoch(weatherMap!["sys"]["sunset"] * 1000)).format("h:mm:a")}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70),
              ),
              SizedBox(
                height: 50,
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: forecastMap!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(right: 8),
                        color: Colors.lightGreen[200],
                        width: 90,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${Jiffy("${forecastMap!["list"][index]["dt_txt"]}").format("EEE , h:mm")}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "${forecastMap!["list"][index]["main"]["temp_min"]}./${forecastMap!["list"][index]["main"]["temp_max"]}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              "${forecastMap!["list"][index]["main"]["sea_level"]}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
