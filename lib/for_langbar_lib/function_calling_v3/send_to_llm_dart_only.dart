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

  factory ToolResponse.fromJson(Map<String, dynamic> json, bool trelis) {
    var functionResponseEncodedIn = 'function_call';
    if (trelis) {
      functionResponseEncodedIn = 'content';
    }
    var functionCallJsonRaw =
        json['choices'][0]['message'][functionResponseEncodedIn];
    var functionCallJson;
    if (trelis) {
      functionCallJson = jsonDecode(functionCallJsonRaw);
    } else {
      functionCallJson = functionCallJsonRaw;
    }
    var parametersJson = functionCallJson['arguments'];
    if (parametersJson is String) {
      parametersJson = jsonDecode(parametersJson);
    }
    var parameters = parametersJson as Map<String, dynamic>;
    return ToolResponse(
      name: functionCallJson['name'],
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

var memory = ConversationBufferWindowMemory2(); // default window length is 5

/**
 * Send a message to the language model.
 *
 * @param functions A list of function descriptions.
 * @param query The user's message.
 * @param Include function calling the format on a format of LLM finetuned in the Trelis format:
 * function-metadata is encoded in one of the messages with role function_metadata in the format of
 * openai (agent-)tools (see https://beta.openai.com/docs/api-reference/completions/create-completion/): for Trelis format see:
 * https://huggingface.co/Trelis/openchat_3.5-function-calling-v3
 *
 * @returns A ToolResponse.
 */
Future<ToolResponse> sendToLLM(
    List<FunctionDescription> functions, String query,
    {bool trelis = false}) async {
  var functionsList = functions.map((e) => e.toV3Json()).toList();
  var functionsMessage = Message(
    role: 'function_metadata',
    content: jsonEncode(functionsList),
  );
  List<Message> messages = [];
  if (!trelis) {
    messages.add(Message(
        role: 'system',
        content:
            'Never directly answer a question yourself, but always use a function call.'));
  }
  if (trelis) {
    messages.add(functionsMessage);
  }
  // messages.add(functionsMessage);
  var userMessage = Message(role: 'user', content: query);
  messages.addAll(memory.getMessages());
  messages.add(userMessage);
  var temperature = 0.0;
  if (trelis) {
    temperature = 0.01;
  }
  var modelName = 'gpt-4-1106-preview';
  if (trelis) {
    modelName = 'Trelis/openchat_3.5-function-calling-v3';
  }
  var model = Model(
    model: modelName,
    messages: messages,
    stream: false,
    temperature: temperature,
    functions: trelis ? null : functions,
  );
  var jsonEncodedRequest = jsonEncode(model.toJson());
  print(jsonEncodedRequest);

  try {
    // test3 key

    var uri = 'https://api.openai.com/v1/chat/completions';
    if (trelis) {
      uri = 'http://27.65.59.89:27289/v1/chat/completions';
    }
    var headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (!trelis) {
      headers.addAll(<String, String>{
        'Authorization': 'Bearer $openaikey',
      });
    }
    final response = await http.post(
      Uri.parse(uri),
      // Uri.parse('https://us-central1-llmproxy1.cloudfunctions.net/defaultOpenAIRequest/chat/completions'),
      headers: headers,
      body: jsonEncodedRequest,
    );
    if (response.statusCode == 200) {
// If the server did return a 200 OK response,
// then parse the JSON.
      var jsonDecoded = jsonDecode(response.body) as Map<String, dynamic>;
      var toolResponse = ToolResponse.fromJson(jsonDecoded, trelis);
      memory.add(userMessage);
      var toolResponseJson = toolResponse.toJson().toString();
      if (trelis) {
        // Trelis format
        memory.add(Message(
            role: 'function_call',
            content: toolResponseJson)); // add assistant response to memory
      } else {
        // openai format (v2 that is)
        memory.add(Message(
            role: 'assistant',
            content: null,
            function_call:
                toolResponseJson)); // add assistant response to memory
      }
      return toolResponse;
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
  ], 'raise my creditcard limit to 1000', trelis: true);
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
