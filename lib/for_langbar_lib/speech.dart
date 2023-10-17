import 'my_speech_to_text.dart';

class Speech {
  static final _speech = SpeechToText();

  static Future<bool> toggleRecording(
      {required Function(String text) onResult,
      required Function(bool onListening, String status) onListening}) async {
    if (_speech.statusListener != null) {
      print('statusListener is not null');
    }
    final isAvailable = await _speech.initialize(
        // finalTimeout: Duration(milliseconds: 60),
        onStatus: (status) => onListening(_speech.isListening, status),
        onError: (error) => print('Error $error'));

    // SpeechToTextPlatform.instance
    if (_speech.isListening) {
      _speech.stop();
      return true;
    }

    print('isAvailable $isAvailable');
    if (isAvailable) {
      print('startListening');
      _speech.listen(
        onResult: (value) => onResult(value.recognizedWords),
        listenFor: Duration(seconds: 30),
        pauseFor: Duration(seconds: 2),
        listenMode: ListenMode.confirmation,
        // partialResults: false
      );
    }

    return isAvailable;
  }
}
