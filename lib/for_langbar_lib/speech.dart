import 'package:speech_to_text/speech_to_text.dart';

class Speech {
  static final _speech = SpeechToText();

  static Future<bool> toggleRecording(
      {required Function(String text) onResult,
      required Function(bool onListening, String status) onListening}) async {
    final isAvailable = await _speech.initialize(
        finalTimeout: Duration(milliseconds: 1000),
        onStatus: (status) => onListening(_speech.isListening, status),
        onError: (error) => print('Error $error'));

    if (_speech.isListening) {
      _speech.stop();
      return true;
    }

    if (isAvailable) {
      _speech.listen(
        onResult: (value) => onResult(value.recognizedWords),
        // partialResults: false
      );
    }

    return isAvailable;
  }
}
