import 'package:langchain/langchain.dart';
import 'package:langchain_ollama/langchain_ollama.dart';

final promptTemplate = ChatPromptTemplate.fromTemplates([
  (
    ChatMessageType.system,
    'You are a helpful assistant that translates {input_language} to {output_language}.',
  ),
  (ChatMessageType.human, '{text}'),
]);
final chatModel = ChatOllama(
  defaultOptions: ChatOllamaOptions(
    model: 'llama2',
    temperature: 0,
  ),
);

final chain = promptTemplate | chatModel | StringOutputParser();

void main() async {
  final res = await chain.invoke({
    'input_language': 'English',
    'output_language': 'French',
    'text': 'I love programming.',
  });
  print(res);
}
