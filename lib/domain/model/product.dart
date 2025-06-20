import 'dart:convert';

import 'package:salesforce/domain/model/abstract_entity.dart';

class Product extends AbstractEntity {
  final String description;
  final String name;
  final double price;
  final String img;
  final double rating;
  final bool favorite;

  Product(
    super.id, {
    required this.description,
    required this.name,
    required this.price,
    required this.img,
    required this.rating,
    required this.favorite,
  });

  Product copyWith({
    String? description,
    String? name,
    double? price,
    String? img,
    double? rating,
    bool? favorite,
  }) {
    return Product(
      super.id,
      description: description ?? this.description,
      name: name ?? this.name,
      price: price ?? this.price,
      img: img ?? this.img,
      rating: rating ?? this.rating,
      favorite: favorite ?? this.favorite,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'name': name,
      'price': price,
      'img': img,
      'rating': rating,
      'favorite': favorite,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      map['id'],
      description: map['description'] ?? 'No Description',
      name: map['name'] ?? 'No Name',
      price: (map['price'] as num).toDouble(),
      img: map['img'] ?? '',
      rating: (map['rating'] as num).toDouble(),
      favorite: map['favorite'] == 1,
    );
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Product(id: $id, description: $description, name: $name, price: $price, img: $img, rating: $rating, favotire: $favorite)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        name.hashCode ^
        price.hashCode ^
        img.hashCode;
  }
}
