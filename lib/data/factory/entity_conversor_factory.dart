import 'dart:convert';

import 'package:dart_kafka/dart_kafka.dart';
import 'package:dio/dio.dart';
import 'package:salesforce/data/DTO/kafka_broker_dto.dart';
import 'package:salesforce/domain/model/api_log.dart';
import 'package:salesforce/domain/model/customer.dart';
import 'package:salesforce/domain/model/app_configuration.dart';
import 'package:salesforce/domain/model/kafka_topic_offset.dart';
import 'package:salesforce/domain/model/product.dart';
import 'package:salesforce/domain/transform/transform_customer_raw_api.dart';

class EntityConversorFactory {
  static EntityConversorFactory? _factory;

  EntityConversorFactory._();

  factory EntityConversorFactory() {
    _factory ??= EntityConversorFactory._();
    return _factory!;
  }

  // Database convertions
  static dynamic convertFromDatabaseResponse(Map<String, dynamic>? res) {
    if (res == null) return null;

    final String entity = res['entity'] as String;
    final List rows = res['rows'] as List;

    if (res['isInsert']) return rows[0]['id'];
    if (res['isUpdate']) return 1;

    switch (entity) {
      case 'apiLog':
        return rows.map((e) => ApiLog.fromMap(e)).toList();
      case 'customer':
        return rows.map((e) => Customer.fromMap(e)).toList();
      case 'globalConfiguration':
        return rows.map((e) => AppConfiguration.fromMap(e)).toList().first;
      case 'kafkaTopicOffset':
        return rows.map((e) => KafkaTopicOffset.fromMap(e)).toList();
      case 'product':
        return rows.map((e) => Product.fromMap(e)).toList();
      default:
        return null;
    }
  }

  // Kafka convertions
  static dynamic convertFromKafkaResponse(String? res) {
    if (res == null || res.isEmpty) return null;

    final Map<String, dynamic> decodedRes = jsonDecode(res);

    if (decodedRes.containsKey('topics')) {
      return FetchResponse.fromMap(decodedRes);
    }

    return ProduceResponse.fromMap(decodedRes);
  }

  static List<Map<String, dynamic>> convertBrokerListToMapList({
    required List<Broker> brokers,
  }) {
    return brokers
        .map(
          (e) =>
              KafkaBrokerDto(
                host: e.host,
                port: e.port,
                nodeId: e.nodeId,
                rack: e.rack,
              ).toMap(),
        )
        .toList();
  }

  static List<Broker> convertMapListToBrokerList({
    required List<Map<String, dynamic>> dto,
  }) {
    final List<KafkaBrokerDto> dtos =
        dto.map((e) => KafkaBrokerDto.fromMap(e)).toList();

    return dtos
        .map(
          (e) => Broker(
            host: e.host,
            port: e.port,
            nodeId: e.nodeId,
            rack: e.rack,
          ),
        )
        .toList();
  }

  // Api convertions
  static dynamic convertFromApiResponse({Map<String, dynamic>? res}) {
    if (res == null) return null;

    final String entity = res['entity'] as String;
    final List<Map<String, dynamic>> rows = List<Map<String, dynamic>>.from(
      res['rows'],
    );

    switch (entity) {
      case 'customer':
        return rows
            .map(
              (e) =>
                  Customer.fromMap(TransformCustomerRawApi.transform(raw: e)),
            )
            .toList();

      default:
        return null;
    }
  }

  static Map<String, dynamic> convertDioExceptionToMap({
    required DioException err,
    required int id,
  }) {
    return {
      'id': id,
      'message': err.message,
      'options': _convertReqOptionsToMap(opt: err.requestOptions),
      'type': err.type.toString(),
      'stack': err.stackTrace.toString(),
      'error': err.error.toString(),
    };
  }

  static DioException convertMapToDioException({
    required Map<String, dynamic> map,
  }) {
    return DioException(
      requestOptions: _convertMapToReqOptions(map: map['options']),
      error: map['error'],
      message: map['message'],
      stackTrace: StackTrace.fromString(map['stack']),
      type: _convertDioExceptionTypeFromString(type: map['type']),
    );
  }

  static DioExceptionType _convertDioExceptionTypeFromString({
    required String type,
  }) {
    switch (type) {
      case 'badCertificate':
        return DioExceptionType.badCertificate;
      case 'badResponse':
        return DioExceptionType.badResponse;
      case 'cancel':
        return DioExceptionType.cancel;
      case 'connectionError':
        return DioExceptionType.connectionError;
      case 'connectionTimeout':
        return DioExceptionType.connectionTimeout;
      case 'receiveTimeout':
        return DioExceptionType.receiveTimeout;
      case 'sendTimeout':
        return DioExceptionType.sendTimeout;

      default:
        return DioExceptionType.unknown;
    }
  }

  static Map<String, dynamic> _convertReqOptionsToMap({
    required RequestOptions opt,
  }) {
    return {
      'data': opt.data,
      'path': opt.path,
      'headers': Map<String, dynamic>.from(opt.headers),
      'method': opt.method,
      'queryParams': opt.queryParameters,
      'receiveDataWhenStatusError': opt.receiveDataWhenStatusError,
    };
  }

  static RequestOptions _convertMapToReqOptions({
    required Map<String, dynamic> map,
  }) {
    return RequestOptions(
      path: map['path'],
      data: map['data'],
      headers: map['headers'],
      queryParameters: map['queryParams'],
      method: map['method'],
      receiveDataWhenStatusError: map['receiveDataWhenStatusError'],
    );
  }

  static Map<String, dynamic> convertDioResponseToMap({
    required Response res,
    required int id,
  }) {
    return {
      'id': id,
      'data': res.data,
      'options': _convertReqOptionsToMap(opt: res.requestOptions),
      'statusCode': res.statusCode,
      'statusMessage': res.statusMessage,
    };
  }

  static Response convertMapToDioResponse({required Map<String, dynamic> map}) {
    return Response(
      requestOptions: _convertMapToReqOptions(map: map['options']),
      data: map['data'],
      statusCode: map['statusCode'],
      statusMessage: map['statusMessage'],
    );
  }
}
