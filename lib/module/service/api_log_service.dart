import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/repository/local/local_api_log_repository.dart';
import 'package:salesforce/domain/model/api_log.dart';

class ApiLogService {
  static ApiLogService? _instance;

  ApiLogService._();

  factory ApiLogService() {
    _instance ??= ApiLogService._();
    return _instance!;
  }

  final LocalApiLogRepository _repository = LocalApiLogRepository();

  Future<int> delete({required int id}) async {
    int res = -1;

    try {
      res = await _repository.delete(id);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<int> insert({required ApiLog entity}) async {
    try {
      return await _repository.insert(entity);
    } on Exception {
      rethrow;
    }
  }

  Future<List<ApiLog>> list({
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, dynamic>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<ApiLog> res = [];

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

  Future<int> update({required ApiLog entity}) async {
    int res = -1;

    try {
      res = await _repository.update(entity);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<ApiLog> findById({required int id}) async {
    try {
      return await _repository.findById(id);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchInsert({required List<ApiLog> entities}) async {
    try {
      await _repository.batchInsert(entities);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchDelete({
    required String where,
    required List<Object?> whereArgs,
  }) async {
    try {
      await _repository.batchDelete(where, whereArgs);
    } on Exception {
      rethrow;
    }
  }
}
