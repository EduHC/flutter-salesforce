import 'package:salesforce/data/DTO/database_query_clause_dto.dart';
import 'package:salesforce/domain/enum/enum_database_query_operators.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/module/service/product_service.dart';

class SaleScreenState {
  static SaleScreenState? _instance;

  SaleScreenState._();

  factory SaleScreenState() {
    _instance ??= SaleScreenState._();
    return _instance!;
  }

  final ProductService _productService = ProductService();

  Future<void> handleBtnClick() async {
    List<Product> prds = await _productService.localList(
      whereParams: {
        'name': DatabaseQueryClauseDto(
          operator: DatabaseQueryOperator.notlike,
          value: 'Mug',
        ),
        'id': DatabaseQueryClauseDto(
          operator: DatabaseQueryOperator.diff,
          value: 10,
        ),
        'description': DatabaseQueryClauseDto(
          operator: DatabaseQueryOperator.isnotnull,
          value: null,
        ),
      },
    );

    if (prds.isEmpty) {
      print('EEeeeh carai');
    }
  }
}
