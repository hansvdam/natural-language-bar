import 'package:flutter/material.dart';

import '../../models/forecast.dart';
import '../../utils.dart';

const smallSpacing = 10.0;
const defaultPadding = 16.0;

class SampleScreenTemplate extends StatefulWidget {
  final Map<String, String> _queryParameters;

  SampleScreenTemplate(
      {required this.label,
      required this.toggleLangbarFunction,
      Key? key,
      required Map<String, String> queryParameters})
      : _queryParameters = queryParameters,
        super(key: key) {}

  // static const _placeParam = Parameter('place', 'string', 'place on earth');
  // static const _numDaysParam = Parameter(
  //     'numDays', 'integer', 'The number of days to forecast',
  //     required: false);
  // static const _parameters = [_placeParam, _numDaysParam];
  // static const name = 'forecast';
  //
  // static getTool(BuildContext context) {
  //   return GenericScreenTool(context, name,
  //       'get weather forecast information for a place on earth', _parameters);
  // }

  final String label;

  final Function toggleLangbarFunction;

  @override
  State<SampleScreenTemplate> createState() => _SampleScreenTemplateState();
}

class _SampleScreenTemplateState extends State<SampleScreenTemplate> {
  _SampleScreenTemplateState();

  String? place;
  int? days;

  @override
  void initState() {
    super.initState();
    // days = widget.numDays;
    // place = widget.place;
    updateState();
  }

  void updateState() {
    // if (place != null) {
    //   _controllerOutlined.text = place!;
    //   daysController.text = days.toString();
    //   futureForecast = fetchForecast(place!, days: days);
    // }
  }

  Future<Forecast>? futureForecast;

  @override
  void didUpdateWidget(SampleScreenTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._queryParameters != widget._queryParameters) {
      // place = widget.place ?? place;
      // days = widget.numDays;
      setState(() {
        updateState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(
      Text("recieved parameters: ${widget._queryParameters}"),
    );
    return Scaffold(
        appBar: createAppBar(widget.label, () {
          widget.toggleLangbarFunction();
        }),
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
