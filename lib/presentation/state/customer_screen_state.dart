import 'package:flutter/material.dart';
import 'package:salesforce/domain/model/customer.dart';
import 'package:salesforce/globals.dart';
import 'package:salesforce/module/service/customer_service.dart';
import 'package:salesforce/module/service/kafka_service.dart';

class CustomerScreenState extends ChangeNotifier {
  static CustomerScreenState? _state;

  CustomerScreenState._();

  factory CustomerScreenState() {
    _state ??= CustomerScreenState._();
    return _state!;
  }

  // Variables
  final CustomerService _customerService = CustomerService();
  final KafkaService _kafkaService = KafkaService();
  final Globals _globals = Globals();
  bool _initialLoadDone = false;

  final Set<Customer> _customers = {};
  // Getters
  List<Customer> get customers => _customers.toList();
  bool get initialLoadDone => _initialLoadDone;
  bool get hasError => _globals.hasError;
  String? get errorMsg => _globals.errorMsg;

  Future<void> loadCustomers() async {
    final List<Customer> tmp = await _customerService.localList();
    _customers.clear();
    _customers.addAll(tmp);
    tmp.clear();
    notifyListeners();
  }

  Future<void> createCustomer({required Customer entity}) async {
    await _customerService.localInsert(entity: entity);
  }

  Future<void> doInitialLoadIfNeeded() async {
    if (initialLoadDone) return;
    _initialLoadDone = true;
    await loadCustomers();
  }

  Future<void> handleKafkaButtonClick() async {
    await _kafkaService.doFetchTask();
  }

  Future<void> handleHttpCustomerButtonClick() async {
    await _customerService.syncAndSaveToLocal();
    await loadCustomers();
  }

  Future<void> handleDelButtonClick() async {
    await _customerService.batchDelete(whereParams: {});
    _customers.clear();
    notifyListeners();
  }
}
