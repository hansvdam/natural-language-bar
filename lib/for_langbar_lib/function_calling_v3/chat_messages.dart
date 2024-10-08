import 'llm_request_json_model2.dart';

final class ConversationBufferWindowMemory2 {
  /// {@macro conversation_buffer_window_memory}

  List<Message> messages = [];

  ConversationBufferWindowMemory2();

  /// Number of messages to keep in the buffer.
  final int k = 6;

  List<Message> getMessages() {
    messages =
        messages.length > k ? messages.sublist(messages.length - k) : messages;
    return messages;
  }

  void add(Message userMessage) {
    messages.add(userMessage);
  }

  void clear() {
    messages.clear();
  }
}
