import 'dart:convert';

import 'package:http/http.dart' as http;

import '../ui/models/forecast.dart';

class Place {
  final String displayName;
  final String latitude;
  final String longitude;

  Place(
      {required this.displayName,
      required this.latitude,
      required this.longitude});
}

Future<Forecast> fetchForecast(String placeName, {int? days}) async {
  // https://api.open-meteo.com/v1/forecast?latitude=52.0908&longitude=5.1222&daily=temperature_2m_max&forecast_days=1&timezone=auto
  // {"latitude":52.1,"longitude":5.1199994,"generationtime_ms":0.6630420684814453,"utc_offset_seconds":7200,"timezone":"Europe/Amsterdam","timezone_abbreviation":"CEST","elevation":10.0,"daily_units":{"time":"iso8601","temperature_2m_max":"°C"},"daily":{"time":["2023-09-13"],"temperature_2m_max":[19.6]}}

  // could also have been done using https://open-meteo.com/en/docs/geocoding-api
  var url = Uri.parse('https://geocode.maps.co/search?q={${placeName}');

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
      'forecast_days': (days ?? 1).toString(),
      'timezone': 'auto'
    };

    // for api explanation see: https://open-meteo.com/en/docs
    Uri url = Uri.https(baseUrl, endpoint, queryParams);
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return Forecast.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch data');
    }
  } else {
    throw Exception('Failed to fetch data');
  }
}
