import 'dart:async';
// import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:dart_kafka/dart_kafka.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:salesforce/data/DTO/database_query_clause_dto.dart';
import 'package:salesforce/data/DTO/http_request_dto.dart';
import 'package:salesforce/data/factory/entity_conversor_factory.dart';
import 'package:salesforce/domain/enum/enum_database_query_operators.dart';
import 'package:salesforce/domain/model/api_log.dart';
import 'package:salesforce/module/service/api_log_service.dart';
import 'package:salesforce/module/service/kafka_service.dart';

@pragma("vm:entry-point")
class HttpGateway {
  static HttpGateway? _instance;

  HttpGateway._();

  factory HttpGateway() {
    _instance ??= HttpGateway._();
    return _instance!;
  }

  bool _isClosed = false;
  final Map<int, Completer> _pendingRequests = {};
  final Completer<SendPort> _portCompleter = Completer<SendPort>();
  late SendPort _commandPort;
  late ReceivePort _receivePort;

  Future<SendPort> get portReady => _portCompleter.future;

  static late Dio _dio;
  static final ApiLogService _logService = ApiLogService();
  static final KafkaService _kafkaService = KafkaService();
  static bool isProcessing = false;
  static int waitTimeSeconds = 10;
  static int amountOfExceptions = 0;

  // Initialization and Dispose
  Future<void> spawn() async {
    final RawReceivePort initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();

    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    try {
      FlutterIsolate.spawn(_startHttpIsolate, [initPort.sendPort]);
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    _receivePort = receivePort;

    _receivePort.listen((message) => _handleResponseFromHttp(message));
    _commandPort = await portReady;
  }

  void dispose() {
    if (_isClosed) return;
    _isClosed = true;
    _commandPort.send(HttpRequestDto.shutdown());
    if (_pendingRequests.isEmpty) _receivePort.close();
  }

  Future<Object?> execute({required HttpRequestDto dto}) async {
    final Completer completer = Completer<Object?>();
    _pendingRequests[dto.id] = completer;

    final int logId = await _persistLog(dto: dto);
    Map<String, dynamic> req = dto.copyWith(logId: logId).toMap();
    _commandPort.send(req);

    return completer.future;
  }

  @pragma('vm:entry-point')
  static void _startHttpIsolate(List params) {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final SendPort sendPort = params[0] as SendPort;

    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    _httpCommandHandler(receivePort: receivePort, sendPort: sendPort);
  }

  static _httpCommandHandler({
    required ReceivePort receivePort,
    required SendPort sendPort,
  }) async {
    final commandPort = ReceivePort();
    sendPort.send(commandPort.sendPort);

    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => (status ?? 0) >= 200,
      ),
    );

    _dio.interceptors.add(_defaultHeaders());

    await for (final message in commandPort) {
      final HttpRequestDto dto = HttpRequestDto.fromMap(message);

      try {
        final Response res = await _dio.request(
          dto.uri,
          queryParameters: dto.queryParams,
          data: dto.data,
          options: Options(
            method: dto.method,
            headers: {'x-request-id': dto.logId},
          ),
        );

        sendPort.send(
          EntityConversorFactory.convertDioResponseToMap(res: res, id: dto.id),
        );
      } on DioException catch (err) {
        sendPort.send(
          EntityConversorFactory.convertDioExceptionToMap(err: err, id: dto.id),
        );
      }
    }
  }

  void _handleResponseFromHttp(dynamic message) {
    if (message is SendPort) {
      _portCompleter.complete(message);
      return;
    }

    final Completer completer = _pendingRequests[message['id']]!;

    if (message.containsKey('error')) {
      final DioException exception =
          EntityConversorFactory.convertMapToDioException(map: message);

      completer.completeError(exception);
      _updateLogWithError(exception);
    } else {
      final Response res = EntityConversorFactory.convertMapToDioResponse(
        map: message,
      );

      completer.complete(res);
      _updateLogWithSuccess(res);
    }

    if (_isClosed && _pendingRequests.isEmpty) _receivePort.close();
  }

  // Interceptors
  static InterceptorsWrapper _defaultHeaders() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['Content-Type'] = 'application/json';
        options.headers['Accept'] = 'application/json';

        return handler.next(options);
      },
      onError: (error, handler) async {
        await _retryRequest(error.requestOptions);
        // return handler.reject(error);
      },
    );
  }

  static Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(method: requestOptions.method);
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Log Handler
  static Future<void> _updateLogWithError(DioException error) async {
    Map<String, DatabaseQueryClauseDto> params = {
      'id': DatabaseQueryClauseDto(
        operator: DatabaseQueryOperator.eq,
        value: error.requestOptions.headers['x-request-id'],
      ),
    };
    List<ApiLog> logs = await _logService.list(whereParams: params);

    if (logs.isEmpty) return;

    final ApiLog log = logs[0];

    String newStatus = log.countRetry >= 5 ? 'ERROR' : 'RETRY';
    int newRetryCount = log.countRetry + 1;

    final ApiLog newLog = log.copyWith(
      countRetry: newRetryCount,
      status: newStatus,
      requestBody: log.requestBody
          ?.toString()
          .replaceAllMapped(RegExp(r"'"), (match) => "''")
          .replaceAllMapped(
            RegExp(r'([a-zA-Z0-9_]+):'),
            (match) => '"${match[1]}":',
          ),
      responseBody: error.message
          ?.toString()
          .replaceAllMapped(RegExp(r"'"), (match) => "''")
          .replaceAllMapped(
            RegExp(r'([a-zA-Z0-9_]+):'),
            (match) => '"${match[1]}":',
          ),
      responseCode: error.response?.statusCode,
      finishedAt: DateTime.now(),
      requestDuration: (DateTime.now().difference(log.createdAt)).toString(),
    );

    final List<Topic> topics = [
      Topic(
        topicName: "api_logs",
        partitions: [
          Partition(
            id: 0,
            batch: RecordBatch(
              producerId: null,
              records: [
                Record(
                  attributes: 0,
                  timestampDelta: 0,
                  offsetDelta: 0,
                  timestamp: DateTime.now().millisecondsSinceEpoch,
                  value: newLog.toJson(),
                  headers: [RecordHeader(key: 'origin', value: 'machine')],
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    _kafkaService.produce(topics: topics);

    await _logService.update(entity: newLog);
  }

  static Future<void> _updateLogWithSuccess(Response response) async {
    Map<String, DatabaseQueryClauseDto> params = {
      'id': DatabaseQueryClauseDto(
        operator: DatabaseQueryOperator.eq,
        value: response.requestOptions.headers['x-request-id'],
      ),
    };
    List<ApiLog> logs = await _logService.list(whereParams: params);

    if (logs.isNotEmpty) {
      await _logService.update(
        entity: ApiLog(
          logs[0].id,
          countRetry: logs[0].countRetry + 1,
          createdAt: logs[0].createdAt,
          method: logs[0].method,
          finishedAt: DateTime.now(),
          route: logs[0].route,
          headers: logs[0].headers,
          status: 'SUCCESS',
          queryParams: logs[0].queryParams,
          requestBody: logs[0].requestBody,
          responseBody: response.data
              ?.toString()
              .replaceAllMapped(RegExp(r"'"), (match) => "''")
              .replaceAllMapped(
                RegExp(r'([a-zA-Z0-9_]+):'),
                (match) => '"${match[1]}":',
              ),
          responseCode: response.statusCode,
          requestDuration:
              (DateTime.now().difference(logs[0].createdAt)).toString(),
          sentToKafka: true,
        ),
      );
    }
  }

  static Future<int> _persistLog({
    required HttpRequestDto dto,
    bool isWifiException = false,
  }) async {
    Map<String, DatabaseQueryClauseDto> params = {
      'route': DatabaseQueryClauseDto(
        operator: DatabaseQueryOperator.eq,
        value: '\'${dto.uri}\' ',
      ),
    };

    if (!dto.path.contains('/agenda/')) {
      params['status'] = DatabaseQueryClauseDto(
        operator: DatabaseQueryOperator.eq,
        value: ' \'RETRY\' ',
      );
    }

    if (dto.path.contains('iniciar') || dto.path.contains('finalizar')) {
      params['requestBody'] = DatabaseQueryClauseDto(
        operator: DatabaseQueryOperator.like,
        value: '"idPedidoItem": ${dto.data['idPedidoItem']}',
      );
    }

    List<ApiLog> logs = await _logService.list(whereParams: params);
    int? reqId = logs.isNotEmpty ? logs[0].id : null;

    reqId ??= await _logService.insert(
      entity: ApiLog(
        null,
        method: dto.method,
        countRetry: 0,
        createdAt: DateTime.now(),
        route: dto.uri,
        headers: dto.headers
            .toString()
            .replaceAllMapped(RegExp(r"'"), (match) => "''")
            .replaceAllMapped(
              RegExp(r'([a-zA-Z0-9_]+):'),
              (match) => '"${match[1]}":',
            ),
        status: isWifiException ? 'RETRY' : 'PROCESSING',
        queryParams: dto.queryParams.toString(),
        requestBody: dto.data
            ?.toString()
            .replaceAllMapped(RegExp(r"'"), (match) => "''")
            .replaceAllMapped(
              RegExp(r'([a-zA-Z0-9_]+):'),
              (match) => '"${match[1]}":',
            ),
        sentToKafka: false,
      ),
    );

    return reqId;
  }
}
