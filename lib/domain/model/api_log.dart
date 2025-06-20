import 'dart:convert';

import 'package:salesforce/domain/model/abstract_entity.dart';
import 'package:salesforce/util/util.dart';

class ApiLog extends AbstractEntity {
  final int countRetry;
  final DateTime createdAt;
  final String route;
  final String headers;
  final String status;
  final String method;
  final bool sentToKafka;
  final DateTime? finishedAt;
  final String? queryParams;
  final String? requestBody;
  final String? responseBody;
  final int? responseCode;
  final String? requestDuration;

  ApiLog(
    super.id, {
    required this.countRetry,
    required this.createdAt,
    this.finishedAt,
    required this.route,
    this.queryParams,
    required this.headers,
    this.requestBody,
    this.responseBody,
    this.responseCode,
    required this.status,
    required this.method,
    this.requestDuration,
    required this.sentToKafka,
  });

  ApiLog copyWith({
    int? id,
    int? countRetry,
    DateTime? createdAt,
    DateTime? finishedAt,
    String? route,
    String? headers,
    String? queryParams,
    String? requestBody,
    String? responseBody,
    int? responseCode,
    String? status,
    String? method,
    String? requestDuration,
    bool? sentToKafka,
  }) {
    return ApiLog(
      super.id,
      countRetry: countRetry ?? this.countRetry,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      route: route ?? this.route,
      headers: headers ?? this.headers,
      queryParams: queryParams ?? this.queryParams,
      requestBody: requestBody ?? this.requestBody,
      responseBody: responseBody ?? this.responseBody,
      responseCode: responseCode ?? this.responseCode,
      status: status ?? this.status,
      method: method ?? this.method,
      requestDuration: requestDuration ?? this.requestDuration,
      sentToKafka: sentToKafka ?? this.sentToKafka,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'countRetry': countRetry,
      'createdAt': createdAt.toIso8601String(),
      'finishedAt': finishedAt?.toIso8601String(),
      'route': route,
      'headers': headers,
      'queryParams': queryParams,
      'requestBody': requestBody,
      'responseBody': responseBody,
      'responseCode': responseCode,
      'status': status,
      'method': method,
      'requestDuration': requestDuration,
      'sentToKafka': (sentToKafka) ? 1 : 0,
    };
  }

  factory ApiLog.fromMap(Map<String, dynamic> map) {
    return ApiLog(
      map['id'] as int,
      status: map['status'] as String,
      method: map['method'] as String,
      countRetry: map['countRetry'] as int,
      createdAt: Util.convertToDateTime(map['createdAt']),
      finishedAt: Util.convertToNullableDateTime(map['finishedAt']),
      route: map['route'] as String,
      headers: map['headers'] as String,
      queryParams:
          map['queryParams'] == null ? null : map['queryParams'] as String,
      requestBody:
          map['requestBody'] == null ? null : map['requestBody'] as String,
      responseBody:
          map['responseBody'] == null ? null : map['responseBody'] as String,
      responseCode:
          map['responseCode'] == null ? null : map['responseCode'] as int,
      requestDuration:
          map['requestDuration'] == null
              ? null
              : map['requestDuration'] as String,
      sentToKafka: map['sentToKafka'] == 1,
    );
  }

  factory ApiLog.empty() {
    return ApiLog(
      null,
      countRetry: 0,
      createdAt: DateTime.now(),
      route: '',
      headers: '',
      status: '',
      method: '',
      sentToKafka: false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ApiLog.fromJson(String source) =>
      ApiLog.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ApiLog(id: $id, createdAt: $createdAt, finishedAt: $finishedAt, route: $route, method: $method, headers: $headers, queryParams: $queryParams, requestBody: $requestBody, responseBody: $responseBody, responseCode: $responseCode, status: $status, requestDuration: $requestDuration, sentToKafka: $sentToKafka)';
  }

  @override
  bool operator ==(covariant ApiLog other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.createdAt == createdAt &&
        other.finishedAt == finishedAt &&
        other.route == route &&
        other.headers == headers &&
        other.queryParams == queryParams &&
        other.requestBody == requestBody &&
        other.responseBody == responseBody &&
        other.responseCode == responseCode &&
        other.status == status &&
        other.method == method &&
        other.sentToKafka == sentToKafka &&
        other.requestDuration == requestDuration;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        createdAt.hashCode ^
        finishedAt.hashCode ^
        route.hashCode ^
        headers.hashCode ^
        queryParams.hashCode ^
        requestBody.hashCode ^
        responseBody.hashCode ^
        responseCode.hashCode ^
        status.hashCode ^
        method.hashCode ^
        sentToKafka.hashCode ^
        requestDuration.hashCode;
  }
}
