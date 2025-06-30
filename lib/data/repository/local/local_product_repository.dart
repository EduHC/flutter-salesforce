import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_query_clause_dto.dart';
import 'package:salesforce/data/DTO/database_request_dto.dart';
import 'package:salesforce/data/gateway/database_gateway.dart';
import 'package:salesforce/data/repository/i_generic_local_repository.dart';
import 'package:salesforce/domain/enum/enum_database_query_operators.dart';
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
  Future<bool> batchDelete({
    required Map<String, DatabaseQueryClauseDto> whereParams,
  }) async {
    final String sql = DatabaseUtils.buildDeleteQuery(
      tableName,
      whereParams: whereParams,
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
  Future<void> batchInsert({required List<Product> entities}) async {
    final List<Future> inserts =
        entities.map((e) => insert(entity: e)).toList();
    await Future.wait(inserts);
  }

  @override
  Future<int> delete({required int id}) async {
    String sql = DatabaseUtils.buildDeleteQuery(
      tableName,
      whereParams: {
        'id': DatabaseQueryClauseDto(
          operator: DatabaseQueryOperator.eq,
          value: id,
        ),
      },
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
  Future<Product> findById({required int id}) async {
    final String sql = DatabaseUtils.buildSelectQuery(
      tableName,
      whereParams: {
        'id': DatabaseQueryClauseDto(
          operator: DatabaseQueryOperator.eq,
          value: id,
        ),
      },
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
  Future<int> insert({required Product entity}) async {
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
    Map<String, DatabaseQueryClauseDto>? whereParams,
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
  Future<int> update({required Product entity}) async {
    final String sql = DatabaseUtils.buildUpdateQuery(
      tableName,
      setValues: entity.toMap(),
      whereParams: {
        'id': DatabaseQueryClauseDto(
          operator: DatabaseQueryOperator.eq,
          value: entity.id,
        ),
      },
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
