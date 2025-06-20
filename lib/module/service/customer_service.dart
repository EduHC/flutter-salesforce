import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/repository/api/api_customer_repository.dart';
import 'package:salesforce/data/repository/local/local_customer_repository.dart';
import 'package:salesforce/domain/model/customer.dart';

class CustomerService {
  static CustomerService? _service;

  CustomerService._();

  factory CustomerService() {
    _service ??= CustomerService._();
    return _service!;
  }

  final LocalCustomerRepository _localRepository = LocalCustomerRepository();
  final ApiCustomerRepository _apiRepository = ApiCustomerRepository();
  bool isCronExecuting = false;
  int countOfBlocked = 0;

  Future<int> localDelete({required int id}) async {
    int res = -1;

    try {
      res = await _localRepository.delete(id);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<int> localInsert({required Customer entity}) async {
    try {
      return await _localRepository.insert(entity);
    } on Exception {
      rethrow;
    }
  }

  Future<List<Customer>> localList({
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, dynamic>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) async {
    List<Customer> res = [];

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

  Future<int> localUpdate({required Customer entity}) async {
    int res = -1;

    try {
      res = await _localRepository.update(entity);
    } on Exception {
      rethrow;
    }

    return res;
  }

  Future<Customer> localFindById({required int id}) async {
    try {
      return await _localRepository.findById(id);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchInsert({required List<Customer> entities}) async {
    try {
      await _localRepository.batchInsert(entities);
    } on Exception {
      rethrow;
    }
  }

  Future<void> batchDelete({
    required String where,
    required List<Object?> whereArgs,
  }) async {
    try {
      await _localRepository.batchDelete(where, whereArgs);
    } on Exception {
      rethrow;
    }
  }

  Future<List<Customer>> syncAndSaveToLocal() async {
    // TODO: Add validação de Wi-Fi ativo
    if (isCronExecuting) {
      if (isCronExecuting) countOfBlocked++;
      if (countOfBlocked > 2) isCronExecuting = false;

      return [];
    }
    isCronExecuting = true;

    final List<Customer> customers = await _apiRepository.getAll(params: null);
    await batchInsert(entities: customers);

    isCronExecuting = false;
    countOfBlocked = 0;

    return await localList();
  }
}
