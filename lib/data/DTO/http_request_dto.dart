// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:salesforce/util/util.dart';

class HttpRequestDto<T> {
  final int id;
  final String entity;
  final String method;
  final String host;
  final String path;
  final Map<String, dynamic> queryParams;
  final Map<String, dynamic> headers;
  final dynamic data;
  final bool isShutdown;
  final int? logId;
  late final String uri;

  HttpRequestDto({
    required this.host,
    required this.path,
    required this.method,
    required this.entity,
    required this.queryParams,
    required this.id,
    this.data,
    this.logId,
    this.isShutdown = false,
    Map<String, dynamic>? headers,
  }) : headers = headers ?? {} {
    uri =
        Uri.https(
          host,
          path,
          queryParams.map((key, value) => MapEntry(key, value.toString())),
        ).toString();
  }

  HttpRequestDto.shutdown()
    : isShutdown = true,
      id = Util.generateMsgId(),
      entity = '',
      method = '',
      host = '',
      path = '',
      queryParams = {},
      logId = null,
      data = null,
      headers = {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entity': entity,
      'method': method,
      'path': path,
      'host': host,
      'queryParams': queryParams,
      'headers': headers,
      'data': data,
      'isShutdown': isShutdown,
      'logId': logId,
    };
  }

  static HttpRequestDto fromMap(Map<String, dynamic> map) {
    final dto = HttpRequestDto(
      id: map['id'],
      entity: map['entity'],
      method: map['method'],
      host: map['host'],
      path: map['path'],
      queryParams: map['queryParams'],
      headers: map['headers'],
      data: map['data'],
      isShutdown: map['isShutdown'],
      logId: map['logId'],
    );

    return dto;
  }

  HttpRequestDto<T> copyWith({
    int? id,
    String? entity,
    String? host,
    String? method,
    String? path,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? headers,
    dynamic data,
    bool? isShutdown,
    int? logId,
  }) {
    return HttpRequestDto<T>(
      id: id ?? this.id,
      method: method ?? this.method,
      entity: entity ?? this.entity,
      host: host ?? this.host,
      path: path ?? this.path,
      queryParams: queryParams ?? this.queryParams,
      logId: logId ?? this.logId,
      data: data ?? this.data,
      headers: headers ?? this.headers,
      isShutdown: isShutdown ?? this.isShutdown,
    );
  }
}
