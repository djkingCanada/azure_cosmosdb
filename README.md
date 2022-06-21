[![Pub Package](https://badgen.net/pub/v/azure_cosmosdb)](https://pub.dev/packages/azure_cosmosdb)
[![Dart Platforms](https://badgen.net/pub/dart-platform/azure_cosmosdb)](https://pub.dev/packages/azure_cosmosdb)
[![Flutter Platforms](https://badgen.net/pub/flutter-platform/azure_cosmosdb)](https://pub.dev/packages/azure_cosmosdb)

[![License](https://badgen.net/pub/license/azure_cosmosdb)](https://github.com/d-markey/azure_cosmosdb/blob/master/LICENSE)
[![Null Safety](https://img.shields.io/badge/null-safety-brightgreen)](https://dart.dev/null-safety)
[![Dart Style](https://img.shields.io/badge/style-lints-40c4ff)](https://pub.dev/packages/lints)
[![Pub Points](https://badgen.net/pub/points/azure_cosmosdb)](https://pub.dev/packages/azure_cosmosdb/score)
[![Likes](https://badgen.net/pub/likes/azure_cosmosdb)](https://pub.dev/packages/azure_cosmosdb/score)
[![Popularity](https://badgen.net/pub/popularity/azure_cosmosdb)](https://pub.dev/packages/azure_cosmosdb/score)

[![Last Commit](https://img.shields.io/github/last-commit/d-markey/azure_cosmosdb?logo=git&logoColor=white)](https://github.com/d-markey/azure_cosmosdb/commits)
[![Dart Workflow](https://github.com/d-markey/azure_cosmosdb/actions/workflows/dart.yml/badge.svg?logo=dart)](https://github.com/d-markey/azure_cosmosdb/actions/workflows/dart.yml)
[![Code Lines](https://img.shields.io/badge/dynamic/json?color=blue&label=code%20lines&query=%24.linesValid&url=https%3A%2F%2Fraw.githubusercontent.com%2Fd-markey%2Fazure_cosmosdb%2Fmain%2Fcoverage.json)](https://github.com/d-markey/azure_cosmosdb/tree/main/coverage/html)
[![Code Coverage](https://img.shields.io/badge/dynamic/json?color=blue&label=code%20coverage&query=%24.lineRate&suffix=%25&url=https%3A%2F%2Fraw.githubusercontent.com%2Fd-markey%2Fazure_cosmosdb%2Fmain%2Fcoverage.json)](https://github.com/d-markey/azure_cosmosdb/tree/main/coverage/html)

Azure Cosmos DB SQL API for Dart & Flutter

## Summary

* [Features](#features)
* [Getting Started](#started)
* [Usage](#usage)

## <a name="features"></a>Features

`Server`: the main class used to communicate with your Cosmos DB instance.

`Database`: class representing a CosmosDB database hosted in `Server`.

`Collection`: class representing a CosmosDB collection from a `Database`.

`BaseDocument`: class representing a CosmosDB document stored in a `Collection`.

`Query`: class representing a CosmosDB SQL query to search documents in a `Collection`.

## <a name="started"></a>Getting Started

Import `azure_cosmosdb` from your `pubspec.yaml` file:

```yaml
dependencies:
   azure_cosmosdb: ^0.9.0
```

## <a name="usage"></a>Usage

You should first define a class deriving from `BaseDocument`or `BaseDocumentWithEtag` to model the data you need to store in CosmosDB.

This class must have an `id` and a `toJson()` method returning a `Map<String, dynamic>` JSON object.

It should also implement a static `fromJson(Map json)` method to build instances from a `Map` JSON objects returned by CosmosDB.

For instance:

```dart
import 'package:azure_cosmosdb/azure_cosmosdb.dart' as cosmosdb;

class ToDo extends cosmosdb.BaseDocumentWithEtag {
  ToDo(
    this.id,
    this.label, {
    this.description,
    this.dueDate,
    this.done = false,
  });

  @override
  final String id;

  String label;
  String? description;
  DateTime? dueDate;
  bool done;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'description': description,
        'due-date': dueDate?.toUtc().toIso8601String(),
        'done': done,
      };

  static ToDo fromJson(Map json) {
    var dueDate = json['due-date'];
    if (dueDate != null) {
      dueDate = DateTime.parse(dueDate).toLocal();
    }
    final todo = ToDo(
      json['id'],
      json['label'],
      description: json['description'],
      dueDate: dueDate,
      done: json['done'],
    );
    todo.setEtag(json);
    return todo;
  }
}
```

To manage your documents in CosmosDB:
* establish a connection to get hold of the CosmosDB collection
* register the static `fromJson()` methods with the collection to enable deserialization of your documents
* then add or query your documents!

For instance:

```dart
void main() async {
  // connect to the collection
  final cosmosDB = cosmosdb.Server('https://localhost:8081/', masterKey: '/* your master key*/');
  final database = await cosmosDB.databases.openOrCreate('sample');
  final todoCollection = await database.collections.openOrCreate('todo', partitionKeys: ['/id']);

  // register the builder for ToDo items
  todoCollection.registerBuilder<ToDo>(ToDo.fromJson);

  // create a new item
  final task = ToDo(
    DateTime.now().millisecondsSinceEpoch.toString(),
    'Improve tests',
    dueDate: DateTime.now().add(Duration(days: 3)),
  );

  // save it to the collection
  await todoCollection.add(task);

  print('Added new task ${task.id} - ${task.label}');

  // query the collection
  final tasks = await todoCollection.query<ToDo>(cosmosdb.Query(
    'SELECT * FROM c WHERE c.label = @improvetests',
    params: {'@improvetests': task.label}));

  print('Other tasks:');
  for (var t in tasks.where((_) => _.id != task.id)) {
    String status = 'still pending';
    final dueDate = t.dueDate;
    if (t.done) {
      status = 'done';
    } else if (dueDate != null) {
      if (dueDate.isBefore(DateTime.now())) {
        status = 'overdue since $dueDate';
      } else {
        status = 'expected for $dueDate';
      }
    }
    print('* ${t.id} - ${t.label} - $status');
  }
}
```
