// ignore_for_file: avoid_print, avoid_redundant_argument_values
import 'package:langbar/for_langbar_lib/pinecone/pinecone.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:langchain_ollama/langchain_ollama.dart';
import 'package:langchain_openai/langchain_openai.dart';

import '../openAIKey.dart';

var geminiModel = ChatGoogleGenerativeAI(
    apiKey: getGeminiKey(),
// baseUrl: getLlmBaseUrl(),
    defaultOptions: const ChatGoogleGenerativeAIOptions(temperature: 0.0));

enum AIModel { OpenAI, Gemini, Ollama }

Future<String> conversationalRetrievalChain(String userQuestion) async {
  final embeddings = OpenAIEmbeddings(
      model: 'text-embedding-ada-002',
      apiKey: getSessionToken(),
      baseUrl: getLlmBaseUrl() ?? 'https://api.openai.com/v1');

  // normally never reinitialize this, because on initialization the index is (re)discovered through a call that takes 1000ms, so do this only once per session. IN this case we provide hostUrl, which is a direct link to the index, so we don't need to discover it.
  // This reinit is also more convenenient, becuse we use a dynamic session-token, which is not known at compile time.
  final vectorStore = Pinecone(
    hostUrl: getVectorStoreBaseUrl()!,
    environment: pineConeEnvironment(),
    apiKey: getSessionToken(),
    indexName: pineConeIndexName(),
    embeddings: embeddings,
  );
  final retriever = vectorStore.asRetriever();
  var apiKey2 = getOpenAIKey();
  AIModel useAIModel = AIModel.OpenAI;
  var useOpenAI = false;
  var model;
  switch (useAIModel) {
    case AIModel.OpenAI:
      model = ChatOpenAI(
          apiKey: apiKey2,
          baseUrl: getLlmBaseUrl() ?? 'https://api.openai.com/v1',
          defaultOptions: const ChatOpenAIOptions(
              temperature: 0.0, model: 'gpt-3.5-turbo'));
      break;
    case AIModel.Gemini:
      model = geminiModel;
      break;
    case AIModel.Ollama:
      model = ChatOllama(
        defaultOptions: ChatOllamaOptions(
          model: 'phi',
          temperature: 0,
        ),
      );
      // Add other model here
      break;
    default:
      model = geminiModel;
  }
  const stringOutputParser = StringOutputParser();

  final answerPrompt = ChatPromptTemplate.fromTemplate('''
You are a KNAB representative. Answer the question concisely based only on the following context about KNAB, in its original language:
{context}

Question: {question}''');

  String combineDocuments(
    final List<Document> documents, {
    final String separator = '\n\n',
  }) {
    print(documents);
    return documents.map((final d) => d.metadata["text"]).join(separator);
  }

  final context = Runnable.fromMap({
    'context': Runnable.getItemFromMap('standalone_question') |
        retriever |
        Runnable.fromFunction<List<Document>, String>(
          (final docs, final _) => combineDocuments(docs),
        ),
    'question': Runnable.getItemFromMap('standalone_question'),
  });

  final conversationalQaChain2 =
      context | answerPrompt | model | stringOutputParser;

  var output = "";
  try {
    final res3 = await conversationalQaChain2.invoke({
      'standalone_question': userQuestion,
      'chat_history': <(String, String)>[],
    });
    print(res3);
    output = res3.toString();
  } catch (e) {
    print(e);
    output =
        "An error occurred, while retrieving relevant chunks from a vector database.\nTry to configure a pinecone index for customer support questions in retrieval.dart:\n ${e.toString()}";
  }
  return output;
}
