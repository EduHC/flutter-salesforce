import 'dart:convert';

import 'package:salesforce/domain/model/abstract_entity.dart';

class Sale extends AbstractEntity {
  final int customerId;
  final bool paid;
  final double discount;
  final double total;
  final DateTime createdAt;

  Sale(
    super.id, {
    required this.customerId,
    required this.paid,
    required this.discount,
    required this.total,
    required this.createdAt,
  });

  Sale copyWith({
    int? customerId,
    bool? paid,
    double? discount,
    double? total,
    DateTime? createdAt,
  }) {
    return Sale(
      super.id,
      customerId: customerId ?? this.customerId,
      paid: paid ?? this.paid,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': super.id,
      'customerId': customerId,
      'paid': paid,
      'discount': discount,
      'total': total,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      map['id'],
      customerId: map['customerId'] as int,
      paid: map['paid'] as bool,
      discount: map['discount'] as double,
      total: map['total'] as double,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory Sale.fromJson(String source) =>
      Sale.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Sale(customerId: $customerId, paid: $paid, discount: $discount, total: $total, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant Sale other) {
    if (identical(this, other)) return true;

    return other.customerId == customerId &&
        other.paid == paid &&
        other.discount == discount &&
        other.total == total &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return customerId.hashCode ^
        paid.hashCode ^
        discount.hashCode ^
        total.hashCode ^
        createdAt.hashCode;
  }
}
