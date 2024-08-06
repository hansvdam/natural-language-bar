import 'package:langchain/langchain.dart';

// until the original is fixed we use this.
// historyMessages.sublist(historyMessages.length - k instead of historyMessages.sublist(historyMessages.length - k * 2

// extension ChatMessagesX on List<ChatMessage> {
//   /// This function is to get a string representation of the chat messages
//   /// based on the message content and role.
//   String toBufferString({
//     final String systemPrefix = SystemChatMessage.defaultPrefix,
//     final String humanPrefix = HumanChatMessage.defaultPrefix,
//     final String aiPrefix = AIChatMessage.defaultPrefix,
//     final String functionPrefix = FunctionChatMessage.defaultPrefix,
//   }) {
//     return map(
//       (final m) {
//         return switch (m) {
//           SystemChatMessage _ => '$systemPrefix: ${m.contentAsString}',
//           HumanChatMessage _ => '$humanPrefix: ${m.contentAsString}',
//           AIChatMessage _ => m.functionCall == null
//               ? '$aiPrefix: ${m.contentAsString}'
//               : '$aiPrefix: ${m.functionCall!.name}(${m.functionCall!.arguments})',
//           FunctionChatMessage(name: final n, content: final c) =>
//             '$functionPrefix: $n=$c',
//           final CustomChatMessage m => '${m.role}: ${m.contentAsString}',
//         };
//       },
//     ).join('\n');
//   }
// }

/// {@template conversation_buffer_window_memory}
/// Buffer for storing a conversation in-memory inside a limited size window
/// and then retrieving the messages at a later time.
///
/// It uses [ChatMessageHistory] as in-memory storage by default.
///
/// Example:
/// ```dart
/// final memory = ConversationBufferWindowMemory(k: 10);
/// await memory.saveContext({'foo': 'bar'}, {'bar': 'foo'});
/// final res = await memory.loadMemoryVariables();
/// // {'history': 'Human: bar\nAI: foo'}
/// ```
/// {@endtemplate}
final class MyConversationBufferWindowMemory extends BaseChatMemory {
  /// {@macro conversation_buffer_window_memory}
  MyConversationBufferWindowMemory({
    final BaseChatMessageHistory? chatHistory,
    super.inputKey,
    super.outputKey,
    super.returnMessages = false,
    this.k = 5,
    this.memoryKey = BaseMemory.defaultMemoryKey,
    this.systemPrefix = SystemChatMessage.defaultPrefix,
    this.humanPrefix = HumanChatMessage.defaultPrefix,
    this.aiPrefix = AIChatMessage.defaultPrefix,
    this.toolPrefix = ToolChatMessage.defaultPrefix,
  }) : super(chatHistory: chatHistory ?? ChatMessageHistory());

  /// Number of interactions to store in the buffer.
  final int k;

  /// The memory key to use for the chat history.
  /// This will be passed as input variable to the prompt.
  final String memoryKey;

  /// The prefix to use for system messages if [returnMessages] is false.
  final String systemPrefix;

  /// The prefix to use for human messages if [returnMessages] is false.
  final String humanPrefix;

  /// The prefix to use for AI messages if [returnMessages] is false.
  final String aiPrefix;

  /// The prefix to use for tool messages if [returnMessages] is false.
  final String toolPrefix;

  @override
  Set<String> get memoryKeys => {memoryKey};

  @override
  Future<MemoryVariables> loadMemoryVariables([
    final MemoryInputValues values = const {},
  ]) async {
    final messages = k > 0 ? await _getChatMessages() : <ChatMessage>[];
    if (returnMessages) {
      return {memoryKey: messages};
    }
    return {
      memoryKey: messages.toBufferString(
        systemPrefix: systemPrefix,
        humanPrefix: humanPrefix,
        aiPrefix: aiPrefix,
        toolPrefix: toolPrefix,
      ),
    };
  }

  Future<List<ChatMessage>> _getChatMessages() async {
    final historyMessages = await chatHistory.getChatMessages();
    return historyMessages.length > k
        ? historyMessages.sublist(historyMessages.length - k)
        : historyMessages;
  }
}
