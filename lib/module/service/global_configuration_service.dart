import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/repository/local/local_global_configuration_repository.dart';
import 'package:salesforce/domain/model/app_configuration.dart';

class AppConfigurationService {
  static AppConfigurationService? _instance;

  AppConfigurationService._();

  factory AppConfigurationService() {
    _instance ??= AppConfigurationService._();
    return _instance!;
  }

  final LocalGlobalConfigurationRepository _repository =
      LocalGlobalConfigurationRepository();

  Future<int> delete({required int id}) async {
    int res = -1;

    try {
      res = await _repository.delete(id);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<int> insert({required AppConfiguration entity}) async {
    try {
      return await _repository.insert(entity);
    } on Exception {
      rethrow;
    }
  }

  Future<List<AppConfiguration>> list({
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, dynamic>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<AppConfiguration> res = [];

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

  Future<int> update({required AppConfiguration entity}) async {
    int res = -1;

    try {
      res = await _repository.update(entity);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<AppConfiguration> findById({required int id}) async {
    try {
      return await _repository.findById(id);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchInsert({required List<AppConfiguration> entities}) async {
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
