import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/forecast.dart';
import '../utils.dart';

const smallSpacing = 10.0;

class ForecastScreen extends StatefulWidget {
  String? place;

  /// Creates a RootScreen
  ForecastScreen(
      {required this.label,
      required this.detailsPath,
      required this.bottomSheetFunction,
      Key? key,
      this.place})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  final Function bottomSheetFunction;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class Place {
  final String displayName;
  final String latitude;
  final String longitude;

  Place(
      {required this.displayName,
      required this.latitude,
      required this.longitude});
}

Future<Forecast> fetchForecast(String value) async {
  // https://api.open-meteo.com/v1/forecast?latitude=52.0908&longitude=5.1222&daily=temperature_2m_max&forecast_days=1&timezone=auto
  // {"latitude":52.1,"longitude":5.1199994,"generationtime_ms":0.6630420684814453,"utc_offset_seconds":7200,"timezone":"Europe/Amsterdam","timezone_abbreviation":"CEST","elevation":10.0,"daily_units":{"time":"iso8601","temperature_2m_max":"°C"},"daily":{"time":["2023-09-13"],"temperature_2m_max":[19.6]}}

  var url = Uri.parse('https://geocode.maps.co/search?q={${value}');

  var response1 = await http.get(url);

  if (response1.statusCode == 200) {
    var result = response1.body;

    String jsonArray = result;
    List<dynamic> list = jsonDecode(jsonArray);
    Map<String, dynamic> firstObject = list[0];

    Place place = Place(
      displayName: firstObject['display_name'],
      latitude: firstObject['lat'],
      longitude: firstObject['lon'],
    );

    print('Display Name: ${place.displayName}');
    print('Latitude: ${place.latitude}');
    print('Longitude: ${place.longitude}');

    String baseUrl = "api.open-meteo.com";
    String endpoint = "/v1/forecast";
    Map<String, String> queryParams = {
      'latitude': '${place.latitude}',
      'longitude': '${place.longitude}',
      'daily': 'temperature_2m_max',
      'forecast_days': '1',
      'timezone': 'auto'
    };

    // for api explanation see: https://open-meteo.com/en/docs
    Uri url = Uri.https(baseUrl, endpoint, queryParams);
    var response = await http.get(url);
    // final response = await http.get(Uri.parse(
    //     'https://api.open-meteo.com/v1/forecast?latitude=52.0908&longitude=5.1222&daily=temperature_2m_max&forecast_days=1&timezone=auto'));

    if (response.statusCode == 200) {
      return Forecast.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch data');
    }
  } else {
    throw Exception('Failed to fetch data');
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => controller.clear(),
      );
}

class _ForecastScreenState extends State<ForecastScreen> {
  late TextEditingController _controllerOutlined;

  _ForecastScreenState();

  String? place;

  @override
  void initState() {
    super.initState();
    updatePlace();
  }

  void updatePlace() {
    String? place = widget.place;
    _controllerOutlined = TextEditingController(text: place);
    if (place != null) futureForecast = fetchForecast(place);
  }

  Future<Forecast>? futureForecast;

  @override
  void didUpdateWidget(ForecastScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place != widget.place) {
      setState(() {
        updatePlace();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    var children2 = <Widget>[
      Text('Screen ${widget.label}',
          style: Theme.of(context).textTheme.titleLarge),
      const Padding(padding: EdgeInsets.all(4)),
      Padding(
        padding: const EdgeInsets.all(smallSpacing),
        child: TextField(
          controller: _controllerOutlined,
          onSubmitted: (final String value) {
            setState(() {
              futureForecast = fetchForecast(value);
            });
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _ClearButton(controller: _controllerOutlined),
            labelText: 'Area on earth',
            hintText: 'Area on earth',
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      if (futureForecast != null)
        FutureBuilder<Forecast>(
          future: futureForecast,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(
                  snapshot.data!.daily!.temperature2mMax![0].toString());
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
    ];
    children.addAll(children2);
    return Scaffold(
      appBar: createAppBar(() {
        widget.bottomSheetFunction(context);
      }),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
