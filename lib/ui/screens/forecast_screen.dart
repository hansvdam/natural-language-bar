import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:langbar/for_langchain/tool.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../data/meteo_fetchers.dart';
import '../../for_langbar_lib/generic_screen_tool.dart';
import '../models/forecast.dart';
import '../utils.dart';

const smallSpacing = 10.0;

class ForecastScreen extends StatefulWidget {
  late final String? place;
  late final int numDays;

  final Map<String, String> _queryParameters;

  ForecastScreen(
      {required this.label,
      required this.detailsPath,
      required this.bottomSheetFunction,
      Key? key,
      required Map<String, String> queryParameters})
      : _queryParameters = queryParameters,
        super(key: key) {
    place = _queryParameters[_placeParam.name];
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

  final String label;

  final String detailsPath;

  final Function bottomSheetFunction;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final TextEditingController _controllerOutlined = TextEditingController();
  final TextEditingController daysController = TextEditingController();

  _ForecastScreenState();

  String? place;
  int? days;

  @override
  void initState() {
    super.initState();
    days = widget.numDays;
    place = widget.place;
    updateState();
  }

  void updateState() {
    if (place != null) {
      _controllerOutlined.text = place!;
      daysController.text = days.toString();
      futureForecast = fetchForecast(place!, days: days);
    }
  }

  Future<Forecast>? futureForecast;

  @override
  void didUpdateWidget(ForecastScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._queryParameters != widget._queryParameters) {
      place = widget.place ?? place;
      days = widget.numDays;
      setState(() {
        updateState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // list of dropdown menu entries ranging from 1 to 14
    final List<DropdownMenuEntry<int>> numberOfDaysAhead =
        List<DropdownMenuEntry<int>>.generate(
      15,
      (int index) =>
          DropdownMenuEntry<int>(value: index, label: index.toString()),
    );

    List<Widget> children = [];
    var children2 = <Widget>[
      Text('Screen ${widget.label}',
          style: Theme.of(context).textTheme.titleLarge),
      const Padding(padding: EdgeInsets.all(4)),
      Wrap(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.all(smallSpacing),
              child: SizedBox(
                width: 200.0,
                child: TextField(
                  controller: _controllerOutlined,
                  onSubmitted: (final String value) {
                    setState(() {
                      place = value;
                      updateState();
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
              )),
          Padding(
              padding: const EdgeInsets.all(smallSpacing),
              child: SizedBox(
                  width: 200.0,
                  child: DropdownMenu<int>(
                    menuHeight: 200,
                    controller: daysController,
                    leadingIcon: const Icon(Icons.search),
                    label: const Text('Number of days ahead'),
                    dropdownMenuEntries: numberOfDaysAhead,
                    onSelected: (daysAhead) {
                      setState(() {
                        days = daysAhead;
                        updateState();
                      });
                    },
                  )))
        ],
      ),
      if (futureForecast != null)
        FutureBuilder<Forecast>(
          future: futureForecast,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var dailyData = snapshot.data!.daily!;
              List<DateTime> dateTimes =
                  dailyData.time!.map((date) => DateTime.parse(date)).toList();
              List<double> temps = dailyData.temperature2mMax!;
              List<Widget> children = [
                Text("max temp from today: " + temps.toString() + " °C")
              ];
              if (temps.length > 1) {
                var bla = IterableZip([dateTimes, temps]).toList();
                children.add(SfCartesianChart(
                    primaryXAxis: DateTimeAxis(),
                    series: <ChartSeries>[
                      // Renders line chart
                      LineSeries<List, DateTime>(
                          dataSource: bla,
                          xValueMapper: (List sales, _) => sales[0],
                          yValueMapper: (List sales, _) => sales[1])
                    ]));
              }
              return Column(mainAxisSize: MainAxisSize.min, children: children);
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