import 'package:flutter/material.dart';

import '../../data/meteo_fetchers.dart';
import '../models/forecast.dart';
import '../utils.dart';
import 'forecast_tool.dart';

const smallSpacing = 10.0;

class ForecastScreen extends StatefulWidget {
  late final String? place;
  late final int num_days;

  final Map<String, String> queryParameters;

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

  static getTool(BuildContext context) {
    return ForecastTool(context);
    // var placeParam = Parameter(ForecastScreen.c, 'string', 'place on earth');
    // return [place, daysAhead];
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
    updateState();
  }

  void updateState() {
    String? place = widget.place;
    if (place != null) {
      _controllerOutlined = TextEditingController(text: place);
      futureForecast = fetchForecast(place, days: widget.num_days);
    }
  }

  Future<Forecast>? futureForecast;

  @override
  void didUpdateWidget(ForecastScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.queryParameters != widget.queryParameters) {
      setState(() {
        updateState();
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
