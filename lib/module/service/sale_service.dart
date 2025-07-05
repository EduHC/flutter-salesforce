class SaleService {
  static SaleService? _instance;

  SaleService._();

  factory SaleService() {
    _instance ??= SaleService._();
    return _instance!;
  }
}
