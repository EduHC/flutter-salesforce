import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_query_clause_dto.dart';
import 'package:salesforce/data/repository/local/local_product_repository.dart';
import 'package:salesforce/domain/model/product.dart';

class ProductService {
  static ProductService? _service;

  ProductService._();

  factory ProductService() {
    _service ??= ProductService._();
    return _service!;
  }

  final LocalProductRepository _localRepository = LocalProductRepository();

  Future<int> localDelete({required int id}) async {
    int res = -1;

    try {
      res = await _localRepository.delete(id: id);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<int> localInsert({required Product entity}) async {
    try {
      return await _localRepository.insert(entity: entity);
    } on Exception {
      rethrow;
    }
  }

  Future<List<Product>> localList({
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, DatabaseQueryClauseDto>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<Product> res = [];

    try {
      res = await _localRepository.list(
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

  Future<int> localUpdate({required Product entity}) async {
    int res = -1;

    try {
      res = await _localRepository.update(entity: entity);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<Product> localFindById({required int id}) async {
    try {
      return await _localRepository.findById(id: id);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchInsert({required List<Product> entities}) async {
    try {
      await _localRepository.batchInsert(entities: entities);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchDelete({
    required Map<String, DatabaseQueryClauseDto> whereParams,
  }) async {
    try {
      await _localRepository.batchDelete(whereParams: whereParams);
    } on Exception {
      rethrow;
    }
  }
}
