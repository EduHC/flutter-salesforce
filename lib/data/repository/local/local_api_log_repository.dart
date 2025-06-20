import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_request_dto.dart';
import 'package:salesforce/data/gateway/database_gateway.dart';
import 'package:salesforce/data/repository/i_generic_local_repository.dart';
import 'package:salesforce/domain/model/api_log.dart';
import 'package:salesforce/util/database_util.dart';
import 'package:salesforce/util/util.dart';

class LocalApiLogRepository implements IGenericLocalRepository<ApiLog> {
  static LocalApiLogRepository? _instance;

  LocalApiLogRepository._();

  factory LocalApiLogRepository() {
    _instance ??= LocalApiLogRepository._();
    return _instance!;
  }

  final String tableName = 'apiLog';
  final DatabaseGateway _gateway = DatabaseGateway();

  @override
  Future<bool> batchDelete(String where, List<Object?> whereArgs) async {
    final String sql = DatabaseUtils.buildDeleteQuery(
      tableName,
      whereParams: {'1': 1},
    );
    final DatabaseRequestDto req = DatabaseRequestDto(
      sql,
      tableName,
      Util.generateMsgId(),
    );

    final res = await _gateway.execute(req: req);

    if (res is Exception) throw res;

    return true;
  }

  @override
  Future<void> batchInsert(List<ApiLog> entities) async {
    if (entities.isEmpty) return;

    for (ApiLog customer in entities) {
      final String sql = DatabaseUtils.buildInsertQuery(
        tableName,
        values: customer.toMap(),
      );

      final DatabaseRequestDto req = DatabaseRequestDto(
        sql,
        tableName,
        Util.generateMsgId(),
      );

      _gateway.execute(req: req);
    }
  }

  @override
  Future<int> delete(int id) async {
    String sql = DatabaseUtils.buildUpdateQuery(
      tableName,
      setValues: {'isActive': 1},
      whereParams: {'id': id},
    );

    DatabaseRequestDto req = DatabaseRequestDto(
      sql,
      tableName,
      Util.generateMsgId(),
    );
    final res = _gateway.execute(req: req);

    if (res is Exception) throw res;

    return res as int;
  }

  @override
  Future<ApiLog> findById(int id) async {
    final String sql = DatabaseUtils.buildSelectQuery(
      tableName,
      whereParams: {'id': id},
    );
    final DatabaseRequestDto req = DatabaseRequestDto(
      sql,
      tableName,
      Util.generateMsgId(),
    );
    final res = _gateway.execute(req: req);

    if (res is Exception) throw res;

    return await res as ApiLog;
  }

  @override
  Future<int> insert(ApiLog entity) async {
    final String sql = DatabaseUtils.buildInsertQuery(
      tableName,
      values: entity.toMap(),
    );
    final DatabaseRequestDto req = DatabaseRequestDto(
      sql,
      tableName,
      Util.generateMsgId(),
    );
    final res = await _gateway.execute(req: req);

    if (res is Exception) throw res;

    return res as int;
  }

  @override
  Future<List<ApiLog>> list({
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, dynamic>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    String sql = DatabaseUtils.buildSelectQuery(
      tableName,
      columns: columns,
      joins: joins,
      whereParams: whereParams,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    final DatabaseRequestDto req = DatabaseRequestDto(
      sql,
      tableName,
      Util.generateMsgId(),
    );
    final res = await _gateway.execute(req: req);

    if (res is Exception) throw res;

    return (res ?? []) as List<ApiLog>;
  }

  @override
  Future<int> update(ApiLog entity) async {
    final String sql = DatabaseUtils.buildUpdateQuery(
      tableName,
      setValues: entity.toMap(),
      whereParams: {'id': entity.id},
    );
    final DatabaseRequestDto req = DatabaseRequestDto(
      sql,
      tableName,
      Util.generateMsgId(),
    );
    final res = await _gateway.execute(req: req);

    if (res is Exception) throw res;

    return 0;
  }
}
