// copied from langchain pinecone so I could add proxying to firebase properly. Added a 'hostUrl' parameter to the constructor, so we can directly link to the pinecone index, instead of having to discover it.
import 'package:http/http.dart' as http;
import 'package:langbar/for_langbar_lib/pinecone/client.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_pinecone/langchain_pinecone.dart';
import 'package:pinecone/pinecone.dart' as pineconeOriginal;
import 'package:uuid/uuid.dart';

/// {@template pinecone}
/// Vector store for Pinecone vector database.
///
/// Pinecone documentation:
/// https://docs.pinecone.io/
///
/// To use Pinecone, you must have an API key. To find your API key, open the
/// Pinecone console and click API Keys.
///
/// Before using this vector store you need to create an index in Pinecone.
/// You can do that in the Pinecone console or using a Pinecone API client.
/// Check out the Pinecone documentation for more information regarding index
/// type and size: https://docs.pinecone.io/docs/choosing-index-type-and-size
///
/// After creating the index, configure the index name in the [indexName]
/// parameter and the cloud region in the [environment] parameter.
///
/// Example:
/// ```dart
/// final vectorStore = Pinecone(
///   apiKey: pineconeApiKey,
///   indexName: 'langchain-dart',
///   environment: 'gcp-starter',
///   embeddings: embeddings,
/// );
/// ```
///
/// Pinecone indexes store records with vector data. Each record in a Pinecone
/// index always contains a unique ID and an array of floats representing a
/// dense vector embedding. It can also contain a sparse vector embedding for
/// hybrid search and metadata key-value pairs for filtered queries.
///
/// When you add documents to the index using this class, the document's page
/// content will be stored in the index's metadata. You can configure the
/// metadata key in the [docPageContentKey] parameter.
///
/// Mind that Pinecone supports 40kb of metadata per vector.
///
/// You can organize the vectors added to an index into partitions, or
/// "namespaces," to limit queries and other vector operations to only one such
/// namespace at a time. You can configure the namespace in the [namespace]
/// parameter.
///
/// ### Filtering
///
/// Metadata filter expressions can be included with queries to limit the
/// search to only vectors matching the filter expression.
///
/// For example:
/// ```dart
/// final vectorStore = VectorStore(...);
/// final res = await vectorStore.similaritySearch(
///   query: 'What should I feed my cat?',
///   config: PineconeSimilaritySearch(
///     k: 5,
///     scoreThreshold: 0.8,
///     filter: {'class: 'cat'},
///   ),
/// );
/// ```
///
/// Pinecone supports a wide range of operators for filtering. Check out the
/// filtering section of the Pinecone docs for more info:
/// https://docs.pinecone.io/docs/metadata-filtering#metadata-query-language
/// {@endtemplate}
class Pinecone extends VectorStore {
  String? hostUrl;

  /// {@macro pinecone}
  Pinecone({
    final String? apiKey,
    final String? baseUrl,
    String? this.hostUrl, // added to provide a direct url to the pinecone index
    final Map<String, String> headers = const {},
    final Map<String, dynamic> queryParams = const {},
    final http.Client? client,
    required this.indexName,
    this.environment = 'gcp-starter',
    this.namespace,
    this.docPageContentKey = 'page_content',
    required super.embeddings,
  }) : _client = PineconeClient(
          apiKey: apiKey ?? '',
          baseUrl: baseUrl,
          headers: headers,
          queryParams: queryParams,
          client: client,
        );

  /// The name of the index.
  final String indexName;

  /// The cloud region for your project. See the Pinecone console > API keys.
  final String environment;

  /// The namespace of the index (optional).
  final String? namespace;

  /// The metadata key used to store the document's page content.
  final String docPageContentKey;

  /// The Pinecone client.
  final PineconeClient _client;

  /// A UUID generator.
  late final Uuid _uuid = const Uuid();

  /// The Pinecone index.
  pineconeOriginal.Index? _index;

  @override
  Future<List<String>> addVectors({
    required final List<List<double>> vectors,
    required final List<Document> documents,
  }) async {
    assert(vectors.length == documents.length);

    final index = await _getIndex();

    final List<String> ids = [];
    final List<pineconeOriginal.Vector> vec = [];

    for (var i = 0; i < documents.length; i++) {
      final doc = documents[i];
      final id = doc.id ?? _uuid.v4();
      final vector = pineconeOriginal.Vector(
        id: id,
        values: vectors[i],
        metadata: {
          ...doc.metadata,
          docPageContentKey: doc.pageContent,
        },
      );
      ids.add(id);
      vec.add(vector);
    }

    await _client.upsertVectors(
      indexName: index.name,
      projectId: index.projectId,
      environment: index.environment,
      request: pineconeOriginal.UpsertRequest(
        namespace: namespace,
        vectors: vec,
      ),
    );
    return ids;
  }

  @override
  Future<void> delete({required final List<String> ids}) async {
    final index = await _getIndex();
    await _client.deleteVectors(
      indexName: index.name,
      projectId: index.projectId,
      environment: index.environment,
      request: pineconeOriginal.DeleteRequest(ids: ids),
    );
  }

  @override
  Future<List<(Document, double)>> similaritySearchByVectorWithScores({
    required final List<double> embedding,
    final VectorStoreSimilaritySearch config = const PineconeSimilaritySearch(),
  }) async {
    final pConfig = PineconeSimilaritySearch.fromBaseConfig(config);
    if (hostUrl != null) {
      _index = pineconeOriginal.Index(
          database: pineconeOriginal.IndexDatabase(
              name: "index1hans",
              metric: pineconeOriginal.SearchMetric.cosine,
              dimension: 1536,
              replicas: 1,
              shards: 1,
              pods: 1,
              podType: null),
          status: pineconeOriginal.IndexStatus(
              host: hostUrl!,
              port: 433,
              state: pineconeOriginal.IndexState.ready,
              ready: true));
    }
    final index = await _getIndex();
    final queryRes = await _client.queryVectors(
      hostUrl: hostUrl,
      indexName: index.name,
      projectId: index.projectId,
      environment: index.environment,
      request: pineconeOriginal.QueryRequest(
        namespace: pConfig.namespace ?? namespace,
        vector: embedding,
        sparseVector: pConfig.sparseVector?.toSparseVector(),
        topK: pConfig.k,
        filter: pConfig.filter,
        includeMetadata: true,
      ),
    );

    final matches = queryRes.matches;
    if (matches.isEmpty) {
      return const [];
    }

    final List<(Document, double)> results = [];
    for (final match in matches) {
      final score = match.score ?? 0.0;
      if (pConfig.scoreThreshold != null && score < pConfig.scoreThreshold!) {
        continue;
      }

      final id = match.id;
      final metadata = match.metadata ?? <String, dynamic>{};
      final document = Document(
        id: id,
        pageContent: metadata[docPageContentKey] as String? ?? '',
        metadata: {
          for (final entry in metadata.entries)
            if (entry.key != docPageContentKey) entry.key: entry.value,
        },
      );
      results.add((document, score));
    }
    return results;
  }

  set index(pineconeOriginal.Index index) {
    _index = index;
  }

  Future<pineconeOriginal.Index> _getIndex() async {
    if (_index != null) {
      return _index!;
    }

    final index = await _client.describeIndex(
      indexName: indexName,
      environment: environment,
    );

    _index = index;
    return index;
  }
}

extension PineconeSparseVectorMapper on PineconeSparseVector {
  /// Converts a [PineconeSparseVector] to a [SparseVector].
  pineconeOriginal.SparseVector toSparseVector() {
    return pineconeOriginal.SparseVector(
      indices: indices,
      values: values,
    );
  }
}
