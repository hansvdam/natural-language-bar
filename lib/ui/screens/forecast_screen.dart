import 'package:flutter/material.dart';
import 'package:langbar/for_langchain/tool.dart';

import '../../data/meteo_fetchers.dart';
import '../../for_langbar_lib/generic_screen_tool.dart';
import '../models/forecast.dart';
import '../utils.dart';

const smallSpacing = 10.0;

class ForecastScreen extends StatefulWidget {
  late final String? place;
  late final int numDays;

  final Map<String, String> _queryParameters;

  /// Creates a RootScreen
  ForecastScreen(
      {required this.label,
      required this.detailsPath,
      required this.bottomSheetFunction,
      Key? key,
      required Map<String, String> queryParameters})
      : _queryParameters = queryParameters,
        super(key: key) {
    place = _queryParameters[_placeParam.name].toString();
    numDays = int.parse(_queryParameters[_numDaysParam.name] ?? "1");
  }

  static const _placeParam = Parameter('place', 'string', 'place on earth');
  static const _numDaysParam = Parameter(
      'numDays', 'integer', 'The number of days to forecast',
      required: false);
  static const _parameters = [_placeParam, _numDaysParam];
  static const name = 'forecast';

  static getTool(BuildContext context) {
    return GenericScreenTool(context, name,
        'get weather forecast information for a place on earth', _parameters);
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
      futureForecast = fetchForecast(place, days: widget.numDays);
    }
  }

  Future<Forecast>? futureForecast;

  @override
  void didUpdateWidget(ForecastScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._queryParameters != widget._queryParameters) {
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
