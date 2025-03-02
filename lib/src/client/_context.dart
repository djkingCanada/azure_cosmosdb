import '../_internal/_http_header.dart';
import '../base_document.dart';
import '../cosmos_db_exceptions.dart';
import '../cosmos_db_server.dart';
import '../partition/partition_key.dart';
import '../permissions/cosmos_db_permission.dart';
import '../queries/paging.dart';

const version = '2.0.0';

class Context {
  Context({
    required this.type,
    this.resId,
    Map<String, String>? headers,
    this.throwOnNotFound = true,
    this.paging,
    this.partitionKey,
    this.token,
    this.onForbidden,
    this.builder,
    this.builders = const {},
  }) {
    if (headers != null) {
      _headers = {...headers};
    }
  }

  final String type;
  final String? resId;
  final bool throwOnNotFound;
  final Paging? paging;
  final PartitionKey? partitionKey;
  final String? token;
  final FutureCallback<CosmosDbPermission?>? onForbidden;
  final DocumentBuilder? builder;
  final Map<Type, DocumentBuilder> builders;

  Map<String, String>? _headers;

  DocumentBuilder<T> getBuilder<T extends BaseDocument>() {
    final builder = this.builder ?? builders[T];
    if (builder == null) throw UnknownDocumentTypeException(T);
    return (data) {
      try {
        return builder(data) as T;
      } catch (ex) {
        throw BadResponseException(ex.toString());
      }
    };
  }

  void addHeader(String name, String value) => (_headers ??= {})[name] = value;

  Context copyWith(
      {Paging? paging,
      PartitionKey? partitionKey,
      Map<String, String>? headers,
      List<String>? removeHeaders,
      DocumentBuilder? builder}) {
    final copy = Context(
      type: type,
      resId: resId,
      builder: builder ?? this.builder,
      paging: paging ?? this.paging,
      partitionKey: partitionKey ?? this.partitionKey,
      token: token,
      onForbidden: onForbidden,
    );
    if (_headers != null) {
      (copy._headers ??= {}).addAll(_headers!);
    }
    if (headers != null) {
      (copy._headers ??= {}).addAll(headers);
    }
    if (removeHeaders != null) {
      copy._headers?.removeWhere((key, value) => removeHeaders.contains(key));
    }
    return copy;
  }

  Map<String, String> getHeaders() {
    final headers = {HttpHeader.userAgent: 'AzureCosmosDb.Dart/$version'};
    if (_headers != null) {
      headers.addAll(_headers!);
    }
    if (partitionKey != null) {
      headers.addAll(partitionKey!.header);
    }
    final maxCount = (paging?.maxCount ?? -1);
    if (maxCount > 0) {
      headers[HttpHeader.msMaxItemCount] = maxCount.toString();
    }
    final continuation = paging?.continuation ?? '';
    if (continuation.isNotEmpty) {
      headers[HttpHeader.msContinuation] = continuation;
    }
    return headers;
  }
}
