// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:salesforce/domain/model/abstract_entity.dart';

class AppConfiguration extends AbstractEntity {
  final bool? isActive;

  AppConfiguration(super.id, {this.isActive});

  AppConfiguration copyWith({int? id, bool? isActive}) {
    return AppConfiguration(super.id, isActive: isActive ?? this.isActive);
  }

  AppConfiguration copyWithNullable({int? id, bool? isActive}) {
    return AppConfiguration(super.id, isActive: isActive ?? this.isActive);
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'isActive': (isActive ?? true) ? 1 : 0};
  }

  factory AppConfiguration.fromMap(Map<String, dynamic> map) {
    return AppConfiguration(
      map['id'],
      isActive: map['isActive'] == 0 ? false : true,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppConfiguration.fromJson(String source) =>
      AppConfiguration.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(covariant AppConfiguration other) {
    if (identical(this, other)) return true;

    return other.id == id && other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^ isActive.hashCode;
  }
}
