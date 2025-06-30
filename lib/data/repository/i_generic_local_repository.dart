import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_query_clause_dto.dart';
import 'package:salesforce/domain/model/abstract_entity.dart';

abstract class IGenericLocalRepository<T extends AbstractEntity> {
  Future<int> insert({required T entity});
  Future<List<T>> list({
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, DatabaseQueryClauseDto>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  });
  Future<T> findById({required int id});
  Future<int> update({required T entity});
  Future<int> delete({required int id});
  Future<bool> batchDelete({
    required Map<String, DatabaseQueryClauseDto> whereParams,
  });
  Future<void> batchInsert({required List<T> entities});
}
