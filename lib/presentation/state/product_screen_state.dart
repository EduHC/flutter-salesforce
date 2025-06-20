import 'package:flutter/foundation.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/module/service/chart_service.dart';
import 'package:salesforce/module/service/product_service.dart';

class ProductScreenState extends ChangeNotifier {
  static ProductScreenState? _instance;

  ProductScreenState._();

  factory ProductScreenState() {
    _instance ??= ProductScreenState._();
    return _instance!;
  }

  final ProductService _service = ProductService();
  final ChartService _chartService = ChartService();
  bool _initialLoadDone = false;

  final Set<Product> _products = {};
  final Set<Product> _filteredProducts = {};
  String _filter = '';

  List<Product> get products => _filteredProducts.toList();
  bool get initialLoadDone => _initialLoadDone;

  // Setters

  void setFilterValue({required String filter}) {
    _filter = filter;
    _filterProducts();
    notifyListeners();
  }

  // Methods

  Future<void> loadProducts() async {
    final List<Product> tmp = await _service.localList();
    _products.clear();
    _products.addAll(tmp);
    _filteredProducts.clear();
    _filteredProducts.addAll(_products);
    tmp.clear();
    notifyListeners();
  }

  Future<void> doInitialLoadIfNeeded() async {
    if (initialLoadDone) return;
    _initialLoadDone = true;
    await loadProducts();
  }

  void _filterProducts() {
    _filteredProducts.clear();
    if (_filter.isEmpty) _filteredProducts.addAll(_products);

    _filteredProducts.addAll(
      _products.where(
        (prod) => prod.name.toUpperCase().contains(_filter.toUpperCase()),
      ),
    );
  }

  // Button Click Handler
  Future<void> handleFavotireButtonClick({required Product prod}) async {
    await _service.localUpdate(entity: prod.copyWith(favorite: !prod.favorite));
    await loadProducts();
  }

  void handleAddToChartButtonClick({required Product prod}) {
    _chartService.addProduct(product: prod);
  }
}
