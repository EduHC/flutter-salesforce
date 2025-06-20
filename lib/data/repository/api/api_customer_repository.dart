import 'package:dio/dio.dart';
import 'package:salesforce/data/DTO/http_request_dto.dart';
import 'package:salesforce/data/DTO/http_response_dto.dart';
import 'package:salesforce/data/factory/entity_conversor_factory.dart';
import 'package:salesforce/data/gateway/http_gateway.dart';
import 'package:salesforce/data/repository/i_generic_remote_repository.dart';
import 'package:salesforce/domain/model/abstract_entity.dart';
import 'package:salesforce/domain/model/customer.dart';
import 'package:salesforce/util/util.dart';

class ApiCustomerRepository implements IGenericRemoteRepository<Customer> {
  static ApiCustomerRepository? _instance;

  ApiCustomerRepository._();

  factory ApiCustomerRepository() {
    _instance ??= ApiCustomerRepository._();
    return _instance!;
  }

  final HttpGateway _gateway = HttpGateway();

  @override
  Future<HttpResponseDto> create(AbstractEntity entity) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseDto> deleteEntity(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Customer>> getAll({required dynamic params}) async {
    final List<Customer> response = [];

    final dto = HttpRequestDto(
      host: 'randomuser.me',
      path: '/api',
      method: 'GET',
      entity: 'customer',
      queryParams: {},
      id: Util.generateMsgId(),
    );

    final res = await _gateway.execute(dto: dto);

    if (res is! Response) return response;
    List? content = res.data?['results'] ?? [];

    if (content == null || content.isEmpty) return response;
    if ((res.statusCode ?? 0) >= 400) return response;

    response.addAll(
      EntityConversorFactory.convertFromApiResponse(
        res: {'entity': 'customer', 'rows': content},
      ),
    );

    return response;
  }

  @override
  Future<Customer> getEntityById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<HttpResponseDto> updateEntity(Customer entity) {
    throw UnimplementedError();
  }
}
