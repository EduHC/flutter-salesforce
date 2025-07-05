import 'package:flutter/material.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/module/service/product_service.dart';

class HomeScreenState extends ChangeNotifier {
  static HomeScreenState? _instance;

  HomeScreenState._();

  factory HomeScreenState() {
    _instance ??= HomeScreenState._();
    return _instance!;
  }

  final ProductService _productService = ProductService();
  final Set<Product> _products = {};
  bool _initialLoadDone = false;

  List<Product> get products => _products.toList();

  Future<void> listProducts() async {
    final List<Product> tmp = await _productService.localList(limit: 4);
    _products.clear();
    _products.addAll(tmp);
    notifyListeners();
  }

  Future<void> doInitialLoadIfNeeded() async {
    if (_initialLoadDone) return;
    _initialLoadDone = true;
    await listProducts();
  }
}
