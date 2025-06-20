import 'dart:convert';

import 'package:salesforce/domain/model/abstract_entity.dart';
import 'package:salesforce/domain/model/customer.dart';
import 'package:salesforce/domain/model/product.dart';

class Sale extends AbstractEntity {
  final Customer customer;
  final List<Product> products;
  final bool paid;
  final double discount;

  Sale(
    super.id, {
    required this.customer,
    required this.products,
    required this.paid,
    required this.discount,
  });

  Sale copyWith({
    Customer? customer,
    List<Product>? products,
    bool? paid,
    double? discount,
  }) {
    return Sale(
      super.id,
      customer: customer ?? this.customer,
      products: products ?? this.products,
      paid: paid ?? this.paid,
      discount: discount ?? this.discount,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer': customer.toMap(),
      'products': products.map((p) => p.toMap()).toList(),
      'paid': paid ? 1 : 0,
      'discount': discount,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      map['id'],
      customer: Customer.fromMap(map['customer']),
      products: List<Product>.from(
        (map['products'] as List).map((item) => Product.fromMap(item)),
      ),
      paid: map['paid'] == 1 || map['paid'] == true,
      discount: (map['discount'] as num).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Sale.fromJson(String source) => Sale.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Sale(id: $id, customer: $customer, products: $products, paid: $paid, discount: $discount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Sale && other.id == id;
  }

  @override
  int get hashCode {
    return customer.hashCode ^
        products.hashCode ^
        paid.hashCode ^
        discount.hashCode;
  }
}
