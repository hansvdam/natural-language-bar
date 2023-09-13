import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils.dart';

const smallSpacing = 10.0;

class ForecastScreen extends StatefulWidget {
  /// Creates a RootScreen
  ForecastScreen({required this.label,
    required this.detailsPath,
    required this.bottomSheetFunction,
    Key? key})
      : super(key: key);

  /// The label
  final String label;

  /// The path to the detail page
  final String detailsPath;

  final Function bottomSheetFunction;

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
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
  final TextEditingController _controllerOutlined = TextEditingController();

  _ForecastScreenState();

  Future<Album>? futureAlbum;

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
              futureAlbum = fetchAlbum();
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
      if (futureAlbum != null)
        FutureBuilder<Album>(
          future: futureAlbum,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.title);
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
