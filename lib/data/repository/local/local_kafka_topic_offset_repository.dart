import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_request_dto.dart';
import 'package:salesforce/data/gateway/database_gateway.dart';
import 'package:salesforce/data/repository/i_generic_local_repository.dart';
import 'package:salesforce/domain/model/kafka_topic_offset.dart';
import 'package:salesforce/util/database_util.dart';
import 'package:salesforce/util/util.dart';

class LocalKafkaTopicOffsetRepository
    implements IGenericLocalRepository<KafkaTopicOffset> {
  static LocalKafkaTopicOffsetRepository? _repository;

  LocalKafkaTopicOffsetRepository._();

  factory LocalKafkaTopicOffsetRepository() {
    _repository ??= LocalKafkaTopicOffsetRepository._();
    return _repository!;
  }

  final String tableName = 'kafkaTopicOffset';
  final DatabaseGateway _gateway = DatabaseGateway();

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
  Future<int> insert(KafkaTopicOffset entity) async {
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
  Future<List<KafkaTopicOffset>> list({
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

    return res as List<KafkaTopicOffset>;
  }

  @override
  Future<void> batchInsert(List<KafkaTopicOffset> customers) async {
    if (customers.isEmpty) return;

    for (KafkaTopicOffset customer in customers) {
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
  Future<int> update(KafkaTopicOffset entity) async {
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

  @override
  Future<KafkaTopicOffset> findById(int id) async {
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

    return await res as KafkaTopicOffset;
  }
}
