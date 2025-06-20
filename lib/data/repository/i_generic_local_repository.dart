import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/domain/model/abstract_entity.dart';

abstract class IGenericLocalRepository<T extends AbstractEntity> {
  Future<int> insert(T entity);
  Future<List<T>> list({
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, dynamic>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  });
  Future<T> findById(int id);
  Future<int> update(T entity);
  Future<int> delete(int id);
  Future<bool> batchDelete(String where, List<Object?> whereArgs);
  Future<void> batchInsert(List<T> entities);
}
