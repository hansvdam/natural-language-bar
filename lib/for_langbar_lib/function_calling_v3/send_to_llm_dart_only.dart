import 'dart:async';
import 'dart:convert';

// import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../for_langchain/for_langchain.dart';
import '../../openAIKey.dart';
import 'chat_messages.dart';
import 'llm_request_json_model2.dart';

class Parameter {
  final String name;
  final String value;

  Parameter(this.name, this.value);

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      json['name'],
      json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

class ToolResponse {
  final String name;
  final Map<String, dynamic> parameters;

  const ToolResponse({
    required this.name,
    required this.parameters,
  });

  factory ToolResponse.fromJson(Map<String, dynamic> json) {
    var parametersJson =
        jsonDecode(json['choices'][0]['message']['function_call']['arguments'])
            as Map<String, dynamic>;
    var parameters = parametersJson;
    return ToolResponse(
      name: json['choices'][0]['message']['function_call']['name'],
      parameters: parameters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'parameters': parameters,
    };
  }
}

var memory = MyConversationBufferWindowMemory2(); // default window length is 5

Future<ToolResponse> sendToLLM(
    List<FunctionDescription> functions, String query,
    {bool trelis = false}) async {
  var functionsMessage = Message(
    role: 'function_metadata',
    content: functions.map((e) => e.toV3Json()).toString(),
  );
  List<Message> messages = [];
  messages.add(Message(
      role: 'system',
      content:
          'Never directly answer a question yourself, but always use a function call.'));
  // messages.add(functionsMessage);
  messages.addAll(memory.getMessages());
  var userMessage = Message(role: 'user', content: query);
  messages.add(userMessage);
  var model = Model(
    model: 'gpt-4-1106-preview',
    messages: messages,
    stream: false,
    temperature: 0.0,
    functions: functions,
  );
  var jsonEncodedRequest = jsonEncode(model.toJson());
  print(jsonEncodedRequest);

  http.Response response;
  try {
    // test3 key
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      // Uri.parse('https://us-central1-llmproxy1.cloudfunctions.net/defaultOpenAIRequest/chat/completions'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openaikey',
      },
      body: jsonEncodedRequest,
    );
    if (response.statusCode == 200) {
// If the server did return a 200 OK response,
// then parse the JSON.
      return ToolResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
// If the server did not return a 200 OK response,
// then throw an exception.
      throw Exception('Failed to load album');
    }
  } catch (e) {
    throw Exception('Failed:' + e.toString());
  }
  // final response = await http
  //     .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
  // if (response.statusCode == 200) {
  //   // If the server did return a 200 OK response,
  //   // then parse the JSON.
  //   return ToolResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  // } else {
  //   // If the server did not return a 200 OK response,
  //   // then throw an exception.
  //   throw Exception('Failed to load album');
  //
}

class ErrorToolResponse {}

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
    return switch (json) {
      {
        'userId': int userId,
        'id': int id,
        'title': String title,
      } =>
        Album(
          userId: userId,
          id: id,
          title: title,
        ),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}

// void main() => runApp(const MyApp());

Future<void> main() async {
  print("Hello World");
  var futureFunctionCall = await sendToLLM([
    FunctionDescription(
        name: 'answer_general_question',
        description: 'Answers general questions.',
        parameters: {
          'type': 'object',
          "properties": {
            'user_question': {
              "description":
                  'The most recent user message as a self contained message, inferring context from previous messages if necessary.',
              "type": 'string',
            },
          },
          "required": ['user_question'],
        }),
    FunctionDescription(
        name: 'creditcard',
        description: 'Show your credit card and maybe perform an action on it',
        parameters: {
          'type': 'object',
          "properties": {
            'limit': {
              "description": 'New limit for the card',
              "type": 'integer',
            },
            'action': {
              "description": 'action to perform on the card',
              "type": 'string',
              "enum": ['replace', 'cancel'],
            },
          },
          "required": [],
        })
  ], 'raise my creditcard limit to 1000');
  print(futureFunctionCall.toJson().toString());
}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   late Future<Album> futureAlbum;
//
//   @override
//   void initState() {
//     super.initState();
//     futureAlbum = fetchAlbum();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fetch Data Example',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text('Fetch Data Example'),
//         ),
//         body: Center(
//           child: FutureBuilder<Album>(
//             future: futureAlbum,
//             builder: (context, snapshot) {
//               if (snapshot.hasData) {
//                 return Text(snapshot.data!.title);
//               } else if (snapshot.hasError) {
//                 return Text('${snapshot.error}');
//               }
//
//               // By default, show a loading spinner.
//               return const CircularProgressIndicator();
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
