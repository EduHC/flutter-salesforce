import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/data/DTO/database_request_dto.dart';
import 'package:salesforce/data/factory/entity_conversor_factory.dart';

@pragma("vm:entry-point")
class DatabaseGateway {
  static DatabaseGateway? _instance;

  DatabaseGateway._();

  factory DatabaseGateway() {
    _instance ??= DatabaseGateway._();
    return _instance!;
  }

  static final int _version = 4;
  static bool _isDrainingQueue = false;
  bool _isClosed = false;

  final Map<int, Completer> _pendingRequests = {};
  final Completer<SendPort> _portCompleter = Completer<SendPort>();
  late SendPort _commandPort;
  late ReceivePort _receivePort;

  Future<SendPort> get portReady => _portCompleter.future;

  // Initialization and Dispose
  Future<void> spawn() async {
    final RawReceivePort initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();

    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    try {
      FlutterIsolate.spawn(_startDbIsolate, [initPort.sendPort]);
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    _receivePort = receivePort;

    _receivePort.listen((message) => _handleResponseFromDb(message));
    _commandPort = await portReady;
  }

  void dispose() {
    if (_isClosed) return;
    _isClosed = true;
    _commandPort.send(DatabaseRequestDto.shutdown());
    if (_pendingRequests.isEmpty) _receivePort.close();
  }

  // SQLite methods to handle databse lifecycle
  static Future<void> _onCreate(Database db, _) async {
    try {
      final batch = db.batch();
      String sql = await rootBundle.loadString(
        'assets/migrations/db-creation.sql',
      );
      var commands = sql
          .split(';')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty);

      for (final command in commands) {
        batch.execute(command);
      }

      sql = await rootBundle.loadString(
        'assets/migrations/base-data-creation.sql',
      );
      commands = sql.split(';').map((c) => c.trim()).where((c) => c.isNotEmpty);

      for (final command in commands) {
        batch.execute(command);
      }

      for (int i = 1; i <= _version; i++) {
        final String path = 'assets/migrations/upgrades/$i.sql';
        String? sql = await _loadAsset(path);

        if (sql == null) continue;

        var commands = sql
            .split(';')
            .map((c) => c.trim())
            .where((c) => c.isNotEmpty);

        for (final command in commands) {
          batch.execute(command);
        }
      }

      await batch.commit(noResult: true);
    } on Exception catch (e) {
      _writeExceptionToFile(e);
    }
  }

  static Future<void> _onConfigure(Database db) async {
    await db.rawQuery('PRAGMA journal_mode = WAL;');
    await db.rawQuery('PRAGMA foreign_keys = ON;');
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // IF the version is 1, doesn't execute the migration 1.sql, it'll start from the 2.sql
    for (int i = (oldVersion + 1); i <= newVersion; i++) {
      final String path = 'assets/migrations/upgrades/$i.sql';
      String? sql = await _loadAsset(path);

      if (sql == null) continue;

      final Batch batch = db.batch();

      var commands = sql
          .split(';')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty);

      for (final command in commands) {
        batch.execute(command);
      }

      try {
        await batch.commit(noResult: true);
      } on Exception catch (e) {
        _writeExceptionToFile(e);
      }
    }
  }

  static Future<void> _onDowngrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // IF the version is 4, it'll execute the 4.sql script until newVersion + 1.sql
    // So, IF the newVersion is 1, it'll execute the scripts: 4.sql, 3.sql, 2.sql
    for (int i = oldVersion; i > newVersion; i--) {
      final String path = 'assets/migrations/downgrades/$i.sql';
      String? sql = await _loadAsset(path);

      if (sql == null) continue;

      final Batch batch = db.batch();

      var commands = sql
          .split(';')
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty);

      for (final command in commands) {
        batch.execute(command);
      }

      try {
        await batch.commit(noResult: true);
      } on Exception catch (e) {
        _writeExceptionToFile(e);
      }
    }
  }

  // Execution in a separate Isolate (thread)
  Future<Object?> execute({required DatabaseRequestDto req}) async {
    final Completer completer = Completer<Object?>();
    _pendingRequests[req.id] = completer;
    _commandPort.send(req.toMap());
    return completer.future;
  }

  static Future<void> _dbCommandHandler(
    ReceivePort receivePort,
    SendPort sendPort,
  ) async {
    final String documentsDirectoryPath =
        await getApplicationDocumentsDirectory().then((value) => value.path);
    final String path = join(documentsDirectoryPath, "database.db");

    final db = await openDatabase(
      path,
      version: _version,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );

    final queue = <DatabaseRequestDto>[];
    final commandPort = ReceivePort();

    sendPort.send(commandPort.sendPort);
    await for (final message in commandPort) {
      final DatabaseRequestDto dto = DatabaseRequestDto.fromMap(message);

      if (dto.isShutdown) {
        await db.close();
        commandPort.close();
        break;
      }

      queue.add(dto);

      if (queue.length == 1) {
        _processQueue(db, queue, sendPort);
      }
    }
  }

  static void _processQueue(
    Database db,
    List<DatabaseRequestDto> queue,
    SendPort sendPort,
  ) async {
    if (_isDrainingQueue) return;
    _isDrainingQueue = true;

    while (queue.isNotEmpty) {
      final cmd = queue.first;
      try {
        dynamic rows = await db.transaction((txn) => txn.rawQuery(cmd.sql));

        final bool isInsert = cmd.sql.contains('INSERT');
        final bool isUpdate = cmd.sql.contains('UPDATE');

        if (isInsert) {
          rows = await db.transaction(
            (txn) => txn.rawQuery("SELECT last_insert_rowid() AS id;"),
          );
        }

        final Map base = {
          'id': cmd.id,
          'entity': cmd.entity,
          'rows': rows,
          'isInsert': isInsert,
          'isUpdate': isUpdate,
        };
        final String encoded = jsonEncode(base);

        sendPort.send(encoded);
      } on Exception catch (e) {
        final Map err = {'error': true, 'msg': e.toString()};
        sendPort.send(jsonEncode(err));
      }

      queue.removeAt(0);
    }

    _isDrainingQueue = false;
  }

  void _handleResponseFromDb(dynamic message) {
    if (message is SendPort) {
      _portCompleter.complete(message);
      return;
    }

    final Map<String, dynamic> response = jsonDecode(message);
    final Completer? completer = _pendingRequests[response['id']];

    if (completer == null) return;

    if (response.containsKey('error') && response['error'] == true) {
      completer.completeError(RemoteError(response['msg'], ''));
    } else {
      completer.complete(
        EntityConversorFactory.convertFromDatabaseResponse(response),
      );
    }

    if (_isClosed && _pendingRequests.isEmpty) _receivePort.close();
  }

  @pragma('vm:entry-point')
  static void _startDbIsolate(List params) {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    final SendPort sendPort = params[0] as SendPort;

    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _dbCommandHandler(receivePort, sendPort);
  }
}

// Helpers
Future<String?> _loadAsset(String path) async {
  try {
    return await rootBundle.loadString(path);
  } on Exception catch (e) {
    debugPrint("[DATABASE-GATEWAY] Error: ${e.toString()}");
    return null;
  } on FlutterError catch (e) {
    debugPrint("[DATABASE-GATEWAY] Error: ${e.toString()}");
    return null;
  }
}

void _writeExceptionToFile(Exception e) async {
  final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
  File f = File('${appDocumentsDir.path}/migration_error.log');

  try {
    if (!f.existsSync()) {
      f.createSync();
    }

    f.writeAsStringSync("$e\n", mode: FileMode.append);
  } on Exception catch (e) {
    debugPrint(
      "${DateTime.now()} || [DATABASE-GATEWAY] Error trying to write logFile: $e",
    );
  }
}
