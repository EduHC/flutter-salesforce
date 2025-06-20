import 'package:flutter/foundation.dart';
import 'package:salesforce/domain/model/product.dart';

class ChartService {
  static ChartService? _instance;

  ChartService._();

  factory ChartService() {
    _instance ??= ChartService._();
    return _instance!;
  }

  final List<Product> _products = [];
  final ValueNotifier<int> _productsQuantity = ValueNotifier(0);

  List<Product> get products => _products;
  ValueNotifier<int> get productsQuantity => _productsQuantity;

  void addProduct({required Product product}) {
    _products.add(product);
    _adjustProductsQuantity();
  }

  void removeProduct({required Product product}) {
    _products.removeWhere((p) => p == product);
    _adjustProductsQuantity();
  }

  void _adjustProductsQuantity() {
    _productsQuantity.value = _products.length;
  }
}
