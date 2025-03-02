import '../base_document.dart';
import '_path_component.dart';
import '_path_parser.dart';
import 'partition_key.dart';

/// Class representing a partition key definition in a Cosmos DB container.
class PartitionKeySpec {
  PartitionKeySpec._(this.paths, this.kind, this.version)
      : _partitionKeyPaths = null;

  factory PartitionKeySpec._cached(List<String> paths,
      {required String kind, required int version}) {
    final pk = PartitionKeySpec._(paths, kind, version);
    var cached = _cache.lookup(pk);
    if (cached == null) {
      _cache.add(pk);
      cached = pk;
    }
    return cached;
  }

  factory PartitionKeySpec._v2(String kind, List<String> paths) =>
      PartitionKeySpec._cached(paths, kind: kind, version: 2);

  /// Partition key with a single property.
  factory PartitionKeySpec(String partitionKey) =>
      PartitionKeySpec._v2('Hash', List.unmodifiable([partitionKey]));

  /// Partition key range with a single property.
  factory PartitionKeySpec.range(String partitionKey) =>
      PartitionKeySpec._v2('Range', List.unmodifiable([partitionKey]));

  /// Creates a partition for multiple keys.
  factory PartitionKeySpec.hierarchical(List<String> partitionKeys) =>
      PartitionKeySpec._v2('MultiHash', List.unmodifiable(partitionKeys));

  /// Default partition key.
  static final id = PartitionKeySpec._(['/id'], 'Hash', 2);

  /// The partition key paths.
  final List<String> paths;

  /// The partition key kind.
  final String kind;

  /// The partition key version.
  final int version;

  /// Serializes this instance to a JSON object.
  dynamic toJson() => {'paths': paths, 'kind': kind, 'version': version};

  /// The partition key components.
  List<List<PathComponent>>? _partitionKeyPaths;

  @override
  int get hashCode => paths.join('\u0000').hashCode;

  @override
  bool operator ==(dynamic other) {
    if (other is! PartitionKeySpec ||
        other.paths.length != paths.length ||
        other.version != version ||
        other.kind != kind) {
      return false;
    } else {
      for (var i = 0; i < paths.length; i++) {
        if (other.paths[i] != paths[i]) {
          return false;
        }
      }
      return true;
    }
  }

  /// Deserializes data from JSON object [json] into a new [PartitionKeySpec] instance.
  /// Handles fields `paths`, `kind`, `version`.
  static PartitionKeySpec fromJson(dynamic json) => PartitionKeySpec._cached(
        json['paths'].cast<String>(),
        kind: json['kind'],
        version: json['version'],
      );

  /// Extracts the [document]'s partition key according to this specification.
  PartitionKey? from(BaseDocument document) {
    try {
      final keys = _extractKeys(document);
      return keys.isEmpty ? null : PartitionKey.hierarchical(keys);
    } catch (ex) {
      return null;
    }
  }

  List<dynamic> _extractKeys(BaseDocument doc) =>
      (_partitionKeyPaths ??= paths.map((pk) => PathParser.parse(pk)).toList())
          .map((p) => p.extract(doc.toJson()))
          .where((k) => k != null)
          .toList();

  static final _cache = <PartitionKeySpec>{id};
}
