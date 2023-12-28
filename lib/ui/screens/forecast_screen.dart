import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../data/meteo_fetchers.dart';
import '../main_scaffolds.dart';
import '../models/forecast.dart';
import '../utils.dart';
import 'default_appbar_scaffold.dart';


class ForecastScreen extends StatefulWidget {
  late final String? place;
  late final int numDays;

  ForecastScreen(
      {required this.label,
      required this.detailsPath,
      Key? key,
      this.place,
      this.numDays = 1})
      : super(key: key) {}

  final String label;

  final String detailsPath;

  static const name = 'forecast';

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  final TextEditingController _controllerOutlined = TextEditingController();
  final TextEditingController daysController = TextEditingController();

  _ForecastScreenState();

  @override
  void initState() {
    super.initState();
    _controllerOutlined.text = widget.place ?? '';
    daysController.text = widget.numDays.toString();
    updateState();
  }

  void updateState() {
    if (_controllerOutlined.text.isNotEmpty && daysController.text.isNotEmpty) {
      var place = _controllerOutlined.text;
      var days = int.parse(daysController.text);
      futureForecast = fetchForecast(place, days: days);
    }
  }

  Future<Forecast>? futureForecast;

  @override
  void didUpdateWidget(ForecastScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.place != widget.place ||
        oldWidget.numDays != widget.numDays) {
      _controllerOutlined.text = widget.place ?? '';
      daysController.text = widget.numDays.toString();
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
      // Text('Screen ${widget.label}',
      //     style: Theme.of(context).textTheme.titleLarge),
      const Padding(padding: EdgeInsets.all(4)),
      Wrap(
        children: [
          Padding(
              padding: const EdgeInsets.all(smallSpacing),
              child: SizedBox(
                width: 200.0,
                child: TextField(
                  controller: _controllerOutlined,
                  onSubmitted: (final String value) {
                    setState(() {
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
                children.add(Flexible(
                    fit: FlexFit.loose,
                    child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(),
                        series: <CartesianSeries>[
                          // Renders line chart
                          LineSeries<List, DateTime>(
                              dataSource: bla,
                              xValueMapper: (List data, _) => data[0],
                              yValueMapper: (List data, _) => data[1])
                        ])));
              }
              return Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                      mainAxisSize: MainAxisSize.min, children: children));
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return const CircularProgressIndicator();
          },
        ),
    ];
    children.addAll(children2);
    return DefaultAppbarScaffold(
        label: widget.label,
        body: Padding(
          padding: const EdgeInsets.only(
              left: defaultPadding, right: defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ));
  }
}
