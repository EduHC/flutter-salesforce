import 'package:salesforce/data/DTO/http_response_dto.dart';
import 'package:salesforce/domain/model/abstract_entity.dart';

abstract class IGenericRemoteRepository<T extends AbstractEntity> {
  Future<HttpResponseDto> create(T entity);
  Future<List<T>> getAll({required dynamic params});
  Future<T> getEntityById(int id);
  Future<HttpResponseDto> updateEntity(T entity);
  Future<HttpResponseDto> deleteEntity(int id);
}
