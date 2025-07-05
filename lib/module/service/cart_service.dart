import 'package:flutter/foundation.dart';
import 'package:salesforce/domain/model/product.dart';

class CartService {
  static CartService? _instance;

  CartService._();

  factory CartService() {
    _instance ??= CartService._();
    return _instance!;
  }

  final List<Product> _products = [];
  final Map<int, int> _quantityByProduct = {};
  final ValueNotifier<int> _productsQuantity = ValueNotifier(0);

  List<Product> get products => _products;
  ValueNotifier<int> get productsQuantity => _productsQuantity;

  double get totalPrice => double.parse(
    _products
        .fold(
          0.0,
          (sum, prod) => sum + (prod.price * _quantityByProduct[prod.id!]!),
        )
        .toStringAsFixed(2),
  );

  void addProduct({required Product product}) {
    if (_quantityByProduct.containsKey(product.id)) {
      _quantityByProduct[product.id!] = _quantityByProduct[product.id!]! + 1;
    } else {
      _products.add(product);
      _quantityByProduct[product.id!] = 1;
    }

    _adjustProductsQuantity();
  }

  void removeProduct({required Product product}) {
    if (_quantityByProduct[product.id!] == 1) {
      removeProductFromCart(product: product);
      return;
    }

    _quantityByProduct[product.id!] = _quantityByProduct[product.id!]! - 1;
    _adjustProductsQuantity();
  }

  void removeProductFromCart({required Product product}) {
    _products.removeWhere((p) => p == product);
    _quantityByProduct.removeWhere((key, value) => key == product.id!);
    _adjustProductsQuantity();
  }

  void _adjustProductsQuantity() {
    int qtd = 0;
    _quantityByProduct.forEach((key, value) => qtd += value);
    _productsQuantity.value = qtd;
  }

  int getProductQuantity({required int id}) {
    return _quantityByProduct[id]!;
  }
}
