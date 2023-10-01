import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:langbar/ui/screens/dummy_screens/suggestions.dart';
import 'package:provider/provider.dart';

import '../../../for_langbar_lib/langbar_stuff.dart';
import '../../utils.dart';
import 'SampleScreenTemplate.dart';

class RoutePlanner extends SampleScreenTemplate {
  RoutePlanner({required super.queryParameters})
      : super(label: 'Route Planner');

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    children.add(
      Text(
          "The $label is not implemented yet, but the navigation structure works."),
    );
    for (var key in queryParameters.keys) {
      children.add(Text("$key: ${queryParameters[key]}"));
    }
    String origin = queryParameters['origin'] ?? '';
    String destination = queryParameters['destination'] ?? '';

    children.add(RoutePlannerRepairedEndPoints(
        origin: origin, destination: destination));

    return Scaffold(
        appBar: createAppBar(context, label, () {
          var langbar = Provider.of<LangBarState>(context, listen: false);
          langbar.toggleLangbar();
        }, leadingHamburger: false),
        body: Padding(
          padding: const EdgeInsets.only(
              left: defaultPadding, right: defaultPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ));
  }
}

class RoutePlannerRepairedEndPoints extends StatefulWidget {
  final String origin;
  final String destination;

  RoutePlannerRepairedEndPoints(
      {required this.origin, required this.destination})
      : super();

  @override
  State<RoutePlannerRepairedEndPoints> createState() =>
      _RoutePlannerRepairedEndPointsState();
}

class _RoutePlannerRepairedEndPointsState
    extends State<RoutePlannerRepairedEndPoints> {
  late Future<String> futureOrigin;
  late Future<String> futureDestination;

  @override
  void initState() {
    super.initState();
    futureOrigin = fetchSuggestion(widget.origin);
    futureDestination = fetchSuggestion(widget.destination);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureOrigin,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            var newOrigin = snapshot.data;
            return FutureBuilder(
                future: futureDestination,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    var newDestination = snapshot.data;
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text('Repaired using 9292 suggest endpoint:'),
                          Text('Origin: $newOrigin'),
                          Text('Destination: $newDestination'),
                        ]);
                  }
                });
          }
        });
  }
}
