import 'package:flutter/material.dart';

import '../../data/meteo_fetchers.dart';
import '../models/forecast.dart';
import '../utils.dart';

const smallSpacing = 10.0;

class ForecastScreen extends StatefulWidget {
  String? place;
  int? num_days;

  Map<String, String> queryParameters;

  /// Creates a RootScreen
  ForecastScreen(
      {required this.label,
      required this.detailsPath,
      required this.bottomSheetFunction,
      Key? key,
      required this.queryParameters})
      : super(key: key) {
    place = queryParameters["place"].toString();
    num_days = int.parse(queryParameters["num_days"] ?? "1");
  }

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  final Function bottomSheetFunction;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  late TextEditingController _controllerOutlined;

  _ForecastScreenState();

  String? place;
  int? days;

  @override
  void initState() {
    super.initState();
    updatePlace();
  }

  void updatePlace() {
    String? place = widget.place;
    int? days = widget.num_days;
    _controllerOutlined = TextEditingController(text: place);
    if (place != null) futureForecast = fetchForecast(place, days: days);
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
            suffixIcon: ClearButton(controller: _controllerOutlined),
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
              return Text("max temp from today: " +
                  snapshot.data!.daily!.temperature2mMax!.toString() +
                  " °C");
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
