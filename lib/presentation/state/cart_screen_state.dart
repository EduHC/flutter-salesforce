import 'package:flutter/material.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/module/service/cart_service.dart';

class CartScreenState extends ChangeNotifier {
  static CartScreenState? _instance;

  CartScreenState._();

  factory CartScreenState() {
    _instance ??= CartScreenState._();
    return _instance!;
  }

  final CartService _service = CartService();

  List<Product> get products => _service.products;
  double get totalPrice => _service.totalPrice;

  void handleRemoveBtnClick({required Product prod}) {
    _service.removeProductFromCart(product: prod);
    notifyListeners();
  }

  void handleMinusBtnClick({required Product prod}) {
    _service.removeProduct(product: prod);
    notifyListeners();
  }

  void handleAddBtnClick({required Product prod}) {
    _service.addProduct(product: prod);
    notifyListeners();
  }

  int getProductQuantity({required int id}) {
    return _service.getProductQuantity(id: id);
  }
}
