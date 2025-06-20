class TransformCustomerRawApi {
  static Map<String, dynamic> transform({required Map<String, dynamic> raw}) {
    final name = raw['name'] ?? {};
    final location = raw['location'] ?? {};
    final streetData = location['street'] ?? {};
    final picture = raw['picture'] ?? {};

    return {
      'id': raw['login']?['uuid']?.hashCode,
      'firstName': name['first']?.toString() ?? 'Unknown',
      'lastName': name['last']?.toString() ?? '',
      'cellphone': raw['cell']?.toString(),
      'cpf': raw['id']?['value']?.toString(),
      'isActive': 1,
      'type': raw.containsKey('cpf') ? 'pf' : 'pj',
      'gender': raw['gender'],
      'email': raw['email']?.toString(),
      'street': "${streetData['number']} ${streetData['name']}",
      'city': location['city']?.toString(),
      'state': location['state']?.toString(),
      'country': location['country']?.toString(),
      'postcode': location['postcode']?.toString(),
      'pictureURL': picture['large']?.toString(),
    };
  }
}
