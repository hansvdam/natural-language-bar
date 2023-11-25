// copied from client.dart in pinecone package: added hostUrl parameter to queryVectors method, so that we can provide a direct url to the pinecone index. In the original the path to
// the actual index was constructed from the indexName and projectId, which was discovered by the pinecone client. This discovery takes 1000ms, so we want to avoid that. We'd also have to proxy the discovery process

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: invalid_annotation_target, unused_import

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:meta/meta.dart';
// import 'schema/schema.dart';
import 'package:pinecone/pinecone.dart' as pineconeOriginal;

/// Enum of HTTP methods
enum HttpMethod { get, put, post, delete, options, head, patch, trace }

// ==========================================
// CLASS: PineconeClientException
// ==========================================

/// HTTP exception handler for PineconeClient
class PineconeClientException implements Exception {
  PineconeClientException({
    required this.message,
    required this.uri,
    required this.method,
    this.code,
    this.body,
  });

  final String message;
  final Uri uri;
  final HttpMethod method;
  final int? code;
  final Object? body;

  @override
  String toString() {
    Object? data;
    try {
      data = body is String ? jsonDecode(body as String) : body.toString();
    } catch (e) {
      data = body.toString();
    }
    final s = JsonEncoder.withIndent('  ').convert({
      'uri': uri.toString(),
      'method': method.name.toUpperCase(),
      'code': code,
      'message': message,
      'body': data,
    });
    return 'PineconeClientException($s)';
  }
}

// ==========================================
// CLASS: PineconeClient
// ==========================================

/// Client for Pinecone API (v.1.1.0)
///
/// No description
class PineconeClient {
  /// Creates a new PineconeClient instance.
  ///
  /// - [PineconeClient.baseUrl] Override base URL (default: server url defined in spec)
  /// - [PineconeClient.headers] Global headers to be sent with every request
  /// - [PineconeClient.queryParams] Global query parameters to be sent with every request
  /// - [PineconeClient.client] Override HTTP client to use for requests
  PineconeClient({
    this.apiKey = '',
    this.baseUrl,
    this.headers = const {},
    this.queryParams = const {},
    http.Client? client,
  })  : assert(
          baseUrl == null || baseUrl.startsWith('http'),
          'baseUrl must start with http',
        ),
        assert(
          baseUrl == null || !baseUrl.endsWith('/'),
          'baseUrl must not end with /',
        ),
        client = RetryClient(client ?? http.Client());

  /// Override base URL (default: server url defined in spec)
  final String? baseUrl;

  /// Global headers to be sent with every request
  final Map<String, String> headers;

  /// Global query parameters to be sent with every request
  final Map<String, dynamic> queryParams;

  /// HTTP client for requests
  final http.Client client;

  /// Authentication related variables
  final String apiKey;

  // ------------------------------------------
  // METHOD: endSession
  // ------------------------------------------

  /// Close the HTTP client and end session
  void endSession() => client.close();

  // ------------------------------------------
  // METHOD: onRequest
  // ------------------------------------------

  /// Middleware for HTTP requests (user can override)
  ///
  /// The request can be of type [http.Request] or [http.MultipartRequest]
  Future<http.BaseRequest> onRequest(http.BaseRequest request) {
    return Future.value(request);
  }

  // ------------------------------------------
  // METHOD: onStreamedResponse
  // ------------------------------------------

  /// Middleware for HTTP streamed responses (user can override)
  Future<http.StreamedResponse> onStreamedResponse(
    final http.StreamedResponse response,
  ) {
    return Future.value(response);
  }

  // ------------------------------------------
  // METHOD: onResponse
  // ------------------------------------------

  /// Middleware for HTTP responses (user can override)
  Future<http.Response> onResponse(http.Response response) {
    return Future.value(response);
  }

  // ------------------------------------------
  // METHOD: _jsonDecode
  // ------------------------------------------

  dynamic _jsonDecode(http.Response r) {
    return json.decode(utf8.decode(r.bodyBytes));
  }

  // ------------------------------------------
  // METHOD: _request
  // ------------------------------------------

  /// Reusable request method
  @protected
  Future<http.StreamedResponse> _request({
    required String baseUrl,
    required String path,
    required HttpMethod method,
    Map<String, dynamic> queryParams = const {},
    Map<String, String> headerParams = const {},
    bool isMultipart = false,
    String requestType = '',
    String responseType = '',
    Object? body,
  }) async {
    // Override with the user provided baseUrl
    baseUrl = this.baseUrl ?? baseUrl;

    // Ensure a baseUrl is provided
    assert(
      baseUrl.isNotEmpty,
      'baseUrl is required, but none defined in spec or provided by user',
    );

    // Add global query parameters
    queryParams = {...queryParams, ...this.queryParams};

    // Ensure query parameters are strings or iterable of strings
    queryParams = queryParams.map((key, value) {
      if (value is Iterable) {
        return MapEntry(key, value.map((v) => v.toString()));
      } else {
        return MapEntry(key, value.toString());
      }
    });

    // Build the request URI
    Uri uri = Uri.parse(baseUrl + path);
    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    // Build the headers
    Map<String, String> headers = {...headerParams};

    // Define the request type being sent to server
    if (requestType.isNotEmpty) {
      headers['content-type'] = requestType;
    }

    // Define the response type expected to receive from server
    if (responseType.isNotEmpty) {
      headers['accept'] = responseType;
    }

    // Add global headers
    headers.addAll(this.headers);

    // Build the request object
    http.BaseRequest request;
    if (isMultipart) {
      // Handle multipart request
      request = http.MultipartRequest(method.name, uri);
      request = request as http.MultipartRequest;
      if (body is List<http.MultipartFile>) {
        request.files.addAll(body);
      } else {
        request.files.add(body as http.MultipartFile);
      }
    } else {
      // Handle normal request
      request = http.Request(method.name, uri);
      request = request as http.Request;
      try {
        if (body != null) {
          request.body = json.encode(body);
        }
      } catch (e) {
        // Handle request encoding error
        throw PineconeClientException(
          uri: uri,
          method: method,
          message: 'Could not encode: ${body.runtimeType}',
          body: e,
        );
      }
    }

    // Add request headers
    request.headers.addAll(headers);

    // Handle user request middleware
    request = await onRequest(request);

    // Submit request
    return await client.send(request);
  }

  // ------------------------------------------
  // METHOD: makeRequestStream
  // ------------------------------------------

  /// Reusable request stream method
  @protected
  Future<http.StreamedResponse> makeRequestStream({
    required String baseUrl,
    required String path,
    required HttpMethod method,
    Map<String, dynamic> queryParams = const {},
    Map<String, String> headerParams = const {},
    bool isMultipart = false,
    String requestType = '',
    String responseType = '',
    Object? body,
  }) async {
    final uri = Uri.parse((this.baseUrl ?? baseUrl) + path);
    late http.StreamedResponse response;
    try {
      response = await _request(
        baseUrl: baseUrl,
        path: path,
        method: method,
        queryParams: queryParams,
        headerParams: headerParams,
        requestType: requestType,
        responseType: responseType,
        body: body,
      );
      // Handle user response middleware
      response = await onStreamedResponse(response);
    } catch (e) {
      // Handle request and response errors
      throw PineconeClientException(
        uri: uri,
        method: method,
        message: 'Response error',
        body: e,
      );
    }

    // Check for successful response
    if ((response.statusCode ~/ 100) == 2) {
      return response;
    }

    // Handle unsuccessful response
    throw PineconeClientException(
      uri: uri,
      method: method,
      message: 'Unsuccessful response',
      code: response.statusCode,
      body: (await http.Response.fromStream(response)).body,
    );
  }

  // ------------------------------------------
  // METHOD: makeRequest
  // ------------------------------------------

  /// Reusable request method
  @protected
  Future<http.Response> makeRequest({
    required String baseUrl,
    required String path,
    required HttpMethod method,
    Map<String, dynamic> queryParams = const {},
    Map<String, String> headerParams = const {},
    bool isMultipart = false,
    String requestType = '',
    String responseType = '',
    Object? body,
  }) async {
    final uri = Uri.parse((this.baseUrl ?? baseUrl) + path);
    late http.Response response;
    try {
      final streamedResponse = await _request(
        baseUrl: baseUrl,
        path: path,
        method: method,
        queryParams: queryParams,
        headerParams: headerParams,
        requestType: requestType,
        responseType: responseType,
        body: body,
      );
      response = await http.Response.fromStream(streamedResponse);
      // Handle user response middleware
      response = await onResponse(response);
    } catch (e) {
      // Handle request and response errors
      throw PineconeClientException(
        uri: uri,
        method: method,
        message: 'Response error',
        body: e,
      );
    }

    // Check for successful response
    if ((response.statusCode ~/ 100) == 2) {
      return response;
    }

    // Handle unsuccessful response
    throw PineconeClientException(
      uri: uri,
      method: method,
      message: 'Unsuccessful response',
      code: response.statusCode,
      body: response.body,
    );
  }

  // ------------------------------------------
  // METHOD: listCollections
  // ------------------------------------------

  /// List collections
  ///
  /// List all collections in your project.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `GET` `https://controller.{environment}.pinecone.io/collections`
  Future<List<String>> listCollections({
    String environment = 'us-west1-gcp-free',
  }) async {
    final r = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/collections',
      method: HttpMethod.get,
      isMultipart: false,
      requestType: '',
      responseType: 'application/json',
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
    return List<String>.from(_jsonDecode(r));
  }

  // ------------------------------------------
  // METHOD: createCollection
  // ------------------------------------------

  /// Create collection
  ///
  /// This operation creates a Pinecone collection.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `request`: No description
  ///
  /// `POST` `https://controller.{environment}.pinecone.io/collections`
  Future<void> createCollection({
    String environment = 'us-west1-gcp-free',
    required pineconeOriginal.CreateCollectionRequest request,
  }) async {
    final _ = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/collections',
      method: HttpMethod.post,
      isMultipart: false,
      requestType: 'application/json',
      responseType: '',
      body: request,
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
  }

  // ------------------------------------------
  // METHOD: describeCollection
  // ------------------------------------------

  /// Describe collection
  ///
  /// Get a description of a collection.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `collectionName`: Name of the collection to operate on.
  ///
  /// `GET` `https://controller.{environment}.pinecone.io/collections/{collectionName}`
  Future<pineconeOriginal.Collection> describeCollection({
    String environment = 'us-west1-gcp-free',
    required String collectionName,
  }) async {
    final r = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/collections/$collectionName',
      method: HttpMethod.get,
      isMultipart: false,
      requestType: '',
      responseType: 'application/json',
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
    return pineconeOriginal.Collection.fromJson(_jsonDecode(r));
  }

  // ------------------------------------------
  // METHOD: deleteCollection
  // ------------------------------------------

  /// Delete collection
  ///
  /// This operation deletes an existing collection.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `collectionName`: Name of the collection to operate on.
  ///
  /// `DELETE` `https://controller.{environment}.pinecone.io/collections/{collectionName}`
  Future<void> deleteCollection({
    String environment = 'us-west1-gcp-free',
    required String collectionName,
  }) async {
    final _ = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/collections/$collectionName',
      method: HttpMethod.delete,
      isMultipart: false,
      requestType: '',
      responseType: '',
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
  }

  // ------------------------------------------
  // METHOD: listIndexes
  // ------------------------------------------

  /// List indexes
  ///
  /// This operation returns a list of your Pinecone indexes.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `GET` `https://controller.{environment}.pinecone.io/databases`
  Future<List<String>> listIndexes({
    String environment = 'us-west1-gcp-free',
  }) async {
    final r = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/databases',
      method: HttpMethod.get,
      isMultipart: false,
      requestType: '',
      responseType: 'application/json',
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
    return List<String>.from(_jsonDecode(r));
  }

  // ------------------------------------------
  // METHOD: createIndex
  // ------------------------------------------

  /// Create index
  ///
  /// This operation creates a Pinecone index.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `request`: No description
  ///
  /// `POST` `https://controller.{environment}.pinecone.io/databases`
  Future<void> createIndex({
    String environment = 'us-west1-gcp-free',
    required pineconeOriginal.CreateIndexRequest request,
  }) async {
    final _ = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/databases',
      method: HttpMethod.post,
      isMultipart: false,
      requestType: 'application/json',
      responseType: '',
      body: request,
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
  }

  // ------------------------------------------
  // METHOD: describeIndex
  // ------------------------------------------

  /// Describe index
  ///
  /// Get a description of an index.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `indexName`: Name of the index to operate on.
  ///
  /// `GET` `https://controller.{environment}.pinecone.io/databases/{indexName}`
  Future<pineconeOriginal.Index> describeIndex({
    String environment = 'us-west1-gcp-free',
    required String indexName,
  }) async {
    final r = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/databases/$indexName',
      method: HttpMethod.get,
      isMultipart: false,
      requestType: '',
      responseType: 'application/json',
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
    return pineconeOriginal.Index.fromJson(_jsonDecode(r));
  }

  // ------------------------------------------
  // METHOD: deleteIndex
  // ------------------------------------------

  /// Delete index
  ///
  /// This operation deletes an existing index.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `indexName`: Name of the index to operate on.
  ///
  /// `DELETE` `https://controller.{environment}.pinecone.io/databases/{indexName}`
  Future<void> deleteIndex({
    String environment = 'us-west1-gcp-free',
    required String indexName,
  }) async {
    final _ = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/databases/$indexName',
      method: HttpMethod.delete,
      isMultipart: false,
      requestType: '',
      responseType: '',
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
  }

  // ------------------------------------------
  // METHOD: configureIndex
  // ------------------------------------------

  /// Configure index
  ///
  /// This operation specifies the pod type and number of replicas for an index.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `indexName`: Name of the index to operate on.
  ///
  /// `request`: Index configuration options
  ///
  /// `PATCH` `https://controller.{environment}.pinecone.io/databases/{indexName}`
  Future<void> configureIndex({
    String environment = 'us-west1-gcp-free',
    required String indexName,
    required pineconeOriginal.ConfigureIndexRequest request,
  }) async {
    final _ = await makeRequest(
      baseUrl: 'https://controller.${environment}.pinecone.io',
      path: '/databases/$indexName',
      method: HttpMethod.patch,
      isMultipart: false,
      requestType: 'application/json',
      responseType: '',
      body: request,
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
  }

  // ------------------------------------------
  // METHOD: describeIndexStats
  // ------------------------------------------

  /// Describe index stats
  ///
  /// This operation returns statistics about the index's contents
  ///
  /// `indexName`: The name of your index. See Pinecone console.
  ///
  /// `projectId`: The id of your project. See Pinecone console.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `request`: No description
  ///
  /// `POST` `https://{index_name}-{project_id}.svc.{environment}.pinecone.io/describe_index_stats`
  Future<pineconeOriginal.IndexStats> describeIndexStats({
    required String indexName,
    required String projectId,
    required String environment,
    pineconeOriginal.IndexStatsRequest? request,
  }) async {
    final r = await makeRequest(
      baseUrl:
          'https://${indexName}-${projectId}.svc.${environment}.pinecone.io',
      path: '/describe_index_stats',
      method: HttpMethod.post,
      isMultipart: false,
      requestType: 'application/json',
      responseType: 'application/json',
      body: request,
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
    return pineconeOriginal.IndexStats.fromJson(_jsonDecode(r));
  }

  // ------------------------------------------
  // METHOD: queryVectors
  // ------------------------------------------

  /// Query vectors
  ///
  /// Retrieves the ids of the most similar items in a namespace, along with their similarity scores.
  ///
  /// `indexName`: The name of your index. See Pinecone console.
  ///
  /// `projectId`: The id of your project. See Pinecone console.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `request`: No description
  ///
  /// `POST` `https://{index_name}-{project_id}.svc.{environment}.pinecone.io/query`
  Future<pineconeOriginal.QueryResponse> queryVectors({
    required String indexName,
    required String projectId,
    required String environment,
    required pineconeOriginal.QueryRequest request,
    String? hostUrl,
  }) async {
    if (hostUrl == null) {
      hostUrl =
          'https://${indexName}-${projectId}.svc.${environment}.pinecone.io';
    }
    final r = await makeRequest(
      baseUrl: hostUrl,
      path: '/query',
      method: HttpMethod.post,
      isMultipart: false,
      requestType: 'application/json',
      responseType: 'application/json',
      body: request,
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
    return pineconeOriginal.QueryResponse.fromJson(_jsonDecode(r));
  }

  // ------------------------------------------
  // METHOD: deleteVectors
  // ------------------------------------------

  /// Delete vectors
  ///
  /// Deletes vectors, by id, from a single namespace.
  ///
  /// `indexName`: The name of your index. See Pinecone console.
  ///
  /// `projectId`: The id of your project. See Pinecone console.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `request`: No description
  ///
  /// `POST` `https://{index_name}-{project_id}.svc.{environment}.pinecone.io/vectors/delete`
  Future<void> deleteVectors({
    required String indexName,
    required String projectId,
    required String environment,
    required pineconeOriginal.DeleteRequest request,
  }) async {
    final _ = await makeRequest(
      baseUrl:
          'https://${indexName}-${projectId}.svc.${environment}.pinecone.io',
      path: '/vectors/delete',
      method: HttpMethod.post,
      isMultipart: false,
      requestType: 'application/json',
      responseType: '',
      body: request,
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
  }

  // ------------------------------------------
  // METHOD: fetchVectors
  // ------------------------------------------

  /// Fetch vectors
  ///
  /// Looks up and returns vectors, by ID, from a single namespace.
  ///
  /// `indexName`: The name of your index. See Pinecone console.
  ///
  /// `projectId`: The id of your project. See Pinecone console.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `ids`: The vector IDs to fetch.
  ///
  /// `namespace`: Option to fetch from a single namespace
  ///
  /// `GET` `https://{index_name}-{project_id}.svc.{environment}.pinecone.io/vectors/fetch`
  Future<pineconeOriginal.FetchResponse> fetchVectors({
    required String indexName,
    required String projectId,
    required String environment,
    required List<String> ids,
    String? namespace,
  }) async {
    final r = await makeRequest(
      baseUrl:
          'https://${indexName}-${projectId}.svc.${environment}.pinecone.io',
      path: '/vectors/fetch',
      method: HttpMethod.get,
      isMultipart: false,
      requestType: '',
      responseType: 'application/json',
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
      queryParams: {
        'ids': ids,
        if (namespace != null) 'namespace': namespace,
      },
    );
    return pineconeOriginal.FetchResponse.fromJson(_jsonDecode(r));
  }

  // ------------------------------------------
  // METHOD: updateVector
  // ------------------------------------------

  /// Update vector
  ///
  /// Updates vector in a namespace
  ///
  /// `indexName`: The name of your index. See Pinecone console.
  ///
  /// `projectId`: The id of your project. See Pinecone console.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `request`: No description
  ///
  /// `POST` `https://{index_name}-{project_id}.svc.{environment}.pinecone.io/vectors/update`
  Future<void> updateVector({
    required String indexName,
    required String projectId,
    required String environment,
    required pineconeOriginal.UpdateRequest request,
  }) async {
    final _ = await makeRequest(
      baseUrl:
          'https://${indexName}-${projectId}.svc.${environment}.pinecone.io',
      path: '/vectors/update',
      method: HttpMethod.post,
      isMultipart: false,
      requestType: 'application/json',
      responseType: '',
      body: request,
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
  }

  // ------------------------------------------
  // METHOD: upsertVectors
  // ------------------------------------------

  /// Upsert vectors
  ///
  /// Writes vectors into a namespace. If a new value is upserted for an existing vector id, it will overwrite the previous value.
  ///
  /// `indexName`: The name of your index. See Pinecone console.
  ///
  /// `projectId`: The id of your project. See Pinecone console.
  ///
  /// `environment`: The region for your project. See Pinecone console
  ///
  /// `request`: No description
  ///
  /// `POST` `https://{index_name}-{project_id}.svc.{environment}.pinecone.io/vectors/upsert`
  Future<pineconeOriginal.UpsertResponse> upsertVectors({
    required String indexName,
    required String projectId,
    required String environment,
    required pineconeOriginal.UpsertRequest request,
  }) async {
    final r = await makeRequest(
      baseUrl:
          'https://${indexName}-${projectId}.svc.${environment}.pinecone.io',
      path: '/vectors/upsert',
      method: HttpMethod.post,
      isMultipart: false,
      requestType: 'application/json',
      responseType: 'application/json',
      body: request,
      headerParams: {
        if (apiKey.isNotEmpty) 'Api-Key': apiKey,
      },
    );
    return pineconeOriginal.UpsertResponse.fromJson(_jsonDecode(r));
  }
}
