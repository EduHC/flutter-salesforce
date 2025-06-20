import 'dart:convert';

import 'package:salesforce/domain/enum/enum_customer_gender.dart';
import 'package:salesforce/domain/enum/enum_customer_type.dart';
import 'package:salesforce/domain/model/abstract_entity.dart';
import 'package:salesforce/util/util.dart';

class Customer extends AbstractEntity {
  final String firstName;
  final String lastName;
  final String? cellphone;
  final String? cpf;
  final bool isActive;
  final EnumCustomerType? type;
  final EnumGender? gender;
  final String? email;
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postcode;
  final String? pictureUrl;

  Customer(
    super.id, {
    required this.firstName,
    required this.lastName,
    this.cellphone,
    this.cpf,
    required this.isActive,
    this.type,
    this.gender,
    this.email,
    this.street,
    this.city,
    this.state,
    this.country,
    this.postcode,
    this.pictureUrl,
  });

  Customer copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? cellphone,
    String? cpf,
    bool? isActive,
    EnumCustomerType? type,
    EnumGender? gender,
    String? email,
    String? street,
    String? city,
    String? state,
    String? country,
    String? postcode,
    String? pictureUrl,
  }) {
    return Customer(
      id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      cellphone: cellphone ?? this.cellphone,
      cpf: cpf ?? this.cpf,
      isActive: isActive ?? this.isActive,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postcode: postcode ?? this.postcode,
      pictureUrl: pictureUrl ?? this.pictureUrl,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'cellphone': cellphone,
      'cpf': cpf,
      'isActive': isActive ? 1 : 0,
      'type': type?.name,
      'gender': gender == EnumGender.f ? 'female' : 'male',
      'email': email,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postcode': postcode,
      'pictureUrl': pictureUrl,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      map['id'],
      firstName: map['firstName']?.toString() ?? 'Unknown',
      lastName: map['lastName']?.toString() ?? '',
      cellphone: map['cellphone']?.toString(),
      cpf: map['cpf']?.toString(),
      isActive: Util.tryConvertToBool(map['isActive']) ?? false,
      type: map['type'] == 'pf' ? EnumCustomerType.pf : EnumCustomerType.pj,
      gender: (map['gender'] == 'female') ? EnumGender.f : EnumGender.m,
      email: map['email']?.toString(),
      street: map['street'],
      city: map['city']?.toString(),
      state: map['state']?.toString(),
      country: map['country']?.toString(),
      postcode: map['postcode']?.toString(),
      pictureUrl: map['large']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Customer.fromJson(String source) =>
      Customer.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Customer(id: $id, name: $firstName $lastName, email: $email, gender: $gender, location: $city, $country)';
  }

  @override
  bool operator ==(covariant Customer other) {
    return id == other.id &&
        firstName == other.firstName &&
        lastName == other.lastName &&
        cellphone == other.cellphone &&
        cpf == other.cpf &&
        isActive == other.isActive &&
        type == other.type &&
        gender == other.gender &&
        email == other.email &&
        street == other.street &&
        city == other.city &&
        state == other.state &&
        country == other.country &&
        postcode == other.postcode &&
        pictureUrl == other.pictureUrl;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        cellphone.hashCode ^
        cpf.hashCode ^
        isActive.hashCode ^
        type.hashCode ^
        gender.hashCode ^
        email.hashCode ^
        street.hashCode ^
        city.hashCode ^
        state.hashCode ^
        country.hashCode ^
        postcode.hashCode ^
        pictureUrl.hashCode;
  }
}
