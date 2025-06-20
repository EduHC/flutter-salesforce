import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_request_dto.dart';
import 'package:salesforce/data/gateway/database_gateway.dart';
import 'package:salesforce/data/repository/i_generic_local_repository.dart';
import 'package:salesforce/domain/model/app_configuration.dart';
import 'package:salesforce/util/database_util.dart';
import 'package:salesforce/util/util.dart';

class LocalGlobalConfigurationRepository
    implements IGenericLocalRepository<AppConfiguration> {
  static LocalGlobalConfigurationRepository? _instance;

  LocalGlobalConfigurationRepository._();

  factory LocalGlobalConfigurationRepository() {
    _instance ??= LocalGlobalConfigurationRepository._();
    return _instance!;
  }

  final String tableName = 'globalConfiguration';
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
  Future<void> batchInsert(List<AppConfiguration> entities) async {
    if (entities.isEmpty) return;

    for (AppConfiguration customer in entities) {
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
  Future<AppConfiguration> findById(int id) async {
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

    return await res as AppConfiguration;
  }

  @override
  Future<int> insert(AppConfiguration entity) async {
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
  Future<List<AppConfiguration>> list({
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

    return res as List<AppConfiguration>;
  }

  @override
  Future<int> update(AppConfiguration entity) async {
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
    final res = _gateway.execute(req: req);

    if (res is Exception) throw res;

    return res as int;
  }
}
