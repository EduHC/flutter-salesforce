import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_query_clause_dto.dart';
import 'package:salesforce/data/repository/local/local_kafka_topic_offset_repository.dart';
import 'package:salesforce/domain/model/kafka_topic_offset.dart';

class KafkaTopicOffsetService {
  static KafkaTopicOffsetService? _service;

  KafkaTopicOffsetService._();

  factory KafkaTopicOffsetService() {
    _service ??= KafkaTopicOffsetService._();
    return _service!;
  }

  final LocalKafkaTopicOffsetRepository _repository =
      LocalKafkaTopicOffsetRepository();

  Future<int> delete({required int id}) async {
    int res = -1;

    try {
      res = await _repository.delete(id: id);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<int> insert({required KafkaTopicOffset entity}) async {
    try {
      return await _repository.insert(entity: entity);
    } on Exception {
      rethrow;
    }
  }

  Future<List<KafkaTopicOffset>> list({
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, DatabaseQueryClauseDto>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<KafkaTopicOffset> res = [];

    try {
      res = await _repository.list(
        whereParams: whereParams,
        columns: columns,
        joins: joins,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<int> update({required KafkaTopicOffset entity}) async {
    int res = -1;

    try {
      res = await _repository.update(entity: entity);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<KafkaTopicOffset> findById({required int id}) async {
    try {
      return await _repository.findById(id: id);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchInsert({required List<KafkaTopicOffset> entities}) async {
    try {
      await _repository.batchInsert(entities: entities);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchDelete({
    required Map<String, DatabaseQueryClauseDto> whereParams,
  }) async {
    try {
      await _repository.batchDelete(whereParams: whereParams);
    } on Exception {
      rethrow;
    }
  }
}
