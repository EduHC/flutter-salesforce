import 'package:salesforce/domain/model/customer.dart';
import 'package:salesforce/module/service/customer_service.dart';

class EntityDependantHandler {
  static EntityDependantHandler? _instance;

  EntityDependantHandler._();

  factory EntityDependantHandler() {
    _instance ??= EntityDependantHandler._();
    return _instance!;
  }

  final CustomerService _customerService = CustomerService();

  Future<void> handle({
    required Map<String, List<Map<String, dynamic>>> entities,
  }) async {
    final List<Customer>? customers =
        entities['customer']?.map((e) => Customer.fromMap(e)).toList();

    if (customers != null && customers.isNotEmpty) {
      await _customerService.batchInsert(entities: customers);
    }
  }
}
