import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_request_dto.dart';
import 'package:salesforce/data/gateway/database_gateway.dart';
import 'package:salesforce/data/repository/i_generic_local_repository.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/util/database_util.dart';
import 'package:salesforce/util/util.dart';

class LocalProductRepository implements IGenericLocalRepository<Product> {
  static LocalProductRepository? _instance;

  LocalProductRepository._();

  factory LocalProductRepository() {
    _instance ??= LocalProductRepository._();
    return _instance!;
  }

  final String tableName = 'product';
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
  Future<void> batchInsert(List<Product> entities) async {
    final List<Future> inserts = entities.map((e) => insert(e)).toList();
    await Future.wait(inserts);
  }

  @override
  Future<int> delete(int id) async {
    String sql = DatabaseUtils.buildDeleteQuery(
      tableName,
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
  Future<Product> findById(int id) async {
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

    return await res as Product;
  }

  @override
  Future<int> insert(Product entity) async {
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
  Future<List<Product>> list({
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

    return res == null ? [] : res as List<Product>;
  }

  @override
  Future<int> update(Product entity) async {
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

    return res as int;
  }
}
