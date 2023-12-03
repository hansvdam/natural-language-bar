// ignore_for_file: avoid_print, avoid_redundant_argument_values
import 'package:langbar/for_langbar_lib/pinecone/pinecone.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

import '../openAIKey.dart';

Future<String> conversationalRetrievalChain(String userQuestion) async {
  final embeddings =
      OpenAIEmbeddings(apiKey: getSessionToken(), baseUrl: getLlmBaseUrl());

  // normally never reinitialize this, because on initialization the index is (re)discovered through a call that takes 1000ms, so do this only once per session. IN this case we provide hostUrl, which is a direct link to the index, so we don't need to discover it.
  // This reinit is also more convenenient, becuse we use a dynamic session-token, which is not known at compile time.
  final vectorStore = Pinecone(
    hostUrl: getLlmBaseUrl()!,
    environment: pineConeEnvironment(),
    apiKey: getSessionToken(),
    indexName: pineConeIndexName(),
    embeddings: embeddings,
  );
  final retriever = vectorStore.asRetriever();
  var apiKey2 = getOpenAIKey();
  final model = ChatOpenAI(
      apiKey: apiKey2,
      baseUrl: getLlmBaseUrl(),
      temperature: 0.0,
      model: 'gpt-4');
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

  final res3 = await conversationalQaChain2.invoke({
    'standalone_question': userQuestion,
    'chat_history': <(String, String)>[],
  });
  print(res3);
  return res3.toString();
}
