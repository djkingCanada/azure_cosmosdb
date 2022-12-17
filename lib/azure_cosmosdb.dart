/// Azure CosmosDB SQL Rest API for Dart/Flutter.
library azure_cosmosdb;

export 'package:retry/retry.dart' show RetryOptions;

export 'src/base_document.dart' hide SpecialDocument;
export 'src/cosmos_db_collection.dart' show CosmosDbCollection;
export 'src/cosmos_db_collections.dart';
export 'src/cosmos_db_database.dart' show CosmosDbDatabase;
export 'src/cosmos_db_databases.dart';
export 'src/cosmos_db_exceptions.dart' hide ContextualizedExceptionExt;
export 'src/cosmos_db_throughput.dart';
export 'src/indexing/bounding_box.dart';
export 'src/indexing/data_type.dart';
export 'src/indexing/geospatial_config.dart';
export 'src/indexing/index_order.dart';
export 'src/indexing/index_path.dart';
export 'src/indexing/indexing_mode.dart';
export 'src/indexing/indexing_policy.dart';
export 'src/indexing/partition.dart';
export 'src/indexing/spatial_index_path.dart';
export 'src/patch/patch.dart';
export 'src/permissions/cosmos_db_permission.dart';
export 'src/permissions/cosmos_db_permissions.dart' show CosmosDbPermissions;
export 'src/permissions/cosmos_db_user.dart';
export 'src/permissions/cosmos_db_users.dart' show CosmosDbUsers;
export 'src/queries/paging.dart' show Paging;
export 'src/queries/query.dart';
export 'src/cosmos_db_server.dart' show CosmosDbServer;
export 'src/spatial/distance_calculator.dart';
export 'src/spatial/distance_calculator_2d.dart';
export 'src/spatial/distance_calculator_3d.dart';
export 'src/spatial/distance_calculator_haversine.dart';
export 'src/spatial/line_string.dart';
export 'src/spatial/multi_polygon.dart';
export 'src/spatial/point.dart';
export 'src/spatial/polygon.dart';
export 'src/spatial/point.dart';
export 'src/spatial/shape.dart';
