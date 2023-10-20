# Natural Language Bar langbar

An input-component for navigating and controlling your app in natural language using an LLM
using [LangChain.dart](https://github.com/davidmigloz/langchain_dart)

A natural language input field sends a user's request to an LLM along with functions defining the screens of the app
using  
'function calling'. The reposnse JSON is used to activate teh appropriate screen in repsonse.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart

### Installation

1. Clone the repo
2. Install dependencies
    ```sh
    flutter pub get
    ```

### provide you OpenAI api key

To run the project you have to provide your own [OpenAI api key](https://platform.openai.com/account/api-keys)

and put it in lib/openAIKey.dart between the quotes:

```dart
String getOpenAIKey() => "";
```

This is not the way for production code, but for now it is the easiest way to get you started.
Also: do **NOT** deploy a web-version of the app this way (local is fine), because you API-key will be blocked within 10
seconds from the first request.

### run the project e.g. from Android Studio

1. Open the project in Android Studio
2. ![run the project](https://raw.githubusercontent.com/hansvdam/langbar/main/docs/img/startingSampleApp.png)

### Further explanation

Currently the this project is still in the form of a sample app.

routes are wrapped in a LangbarWrapper (see file routes.dart), which is responsible for showing the NLB at the bottom of
every screen, but you also omit it on some screens if you prefer.
This file also shows all functional documentation of the routes.

The actual triggering of routes takes place from LangChain Tools. LangChain Tools are automatically (see file
send_to_llm.dart)
extracted from the DocumentedGoRoutes and fed into a LangChain agent that generates the prompt.

![Langbar flow](https://raw.githubusercontent.com/hansvdam/langbar/main/docs/img/langbarflow1.png)
