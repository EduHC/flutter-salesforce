import 'dart:convert';

import 'package:salesforce/domain/model/abstract_entity.dart';

class SaleProduct extends AbstractEntity {
  final int saleId;
  final int quantity;
  final int productId;
  final double price;
  final double discount;

  SaleProduct(
    super.id, {
    required this.saleId,
    required this.quantity,
    required this.productId,
    required this.price,
    required this.discount,
  });

  SaleProduct copyWith({
    int? saleId,
    int? quantity,
    int? productId,
    double? price,
    double? discount,
  }) {
    return SaleProduct(
      super.id,
      saleId: saleId ?? this.saleId,
      quantity: quantity ?? this.quantity,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      discount: discount ?? this.discount,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': super.id,
      'saleId': saleId,
      'quantity': quantity,
      'productId': productId,
      'price': price,
      'discount': discount,
    };
  }

  factory SaleProduct.fromMap(Map<String, dynamic> map) {
    return SaleProduct(
      map['id'],
      saleId: map['saleId'] as int,
      quantity: map['quantity'] as int,
      productId: map['productId'] as int,
      price: map['price'] as double,
      discount: map['discount'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory SaleProduct.fromJson(String source) =>
      SaleProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SaleProduct(saleId: $saleId, quantity: $quantity, productId: $productId, price: $price, discount: $discount)';
  }

  @override
  bool operator ==(covariant SaleProduct other) {
    if (identical(this, other)) return true;

    return other.saleId == saleId &&
        other.quantity == quantity &&
        other.productId == productId &&
        other.price == price &&
        other.discount == discount;
  }

  @override
  int get hashCode {
    return saleId.hashCode ^
        quantity.hashCode ^
        productId.hashCode ^
        price.hashCode ^
        discount.hashCode;
  }
}
