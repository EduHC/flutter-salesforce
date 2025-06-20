import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:dart_kafka/dart_kafka.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:salesforce/data/DTO/kafka_fetch_request_dto.dart';
import 'package:salesforce/data/DTO/kafka_produce_request_dto.dart';
import 'package:salesforce/data/DTO/kafka_request_dto.dart';
import 'package:salesforce/data/factory/entity_conversor_factory.dart';
import 'package:salesforce/globals.dart';
import 'package:salesforce/module/handler/kafka_event_handler.dart';

@pragma("vm:entry-point")
class KafkaGateway {
  static KafkaGateway? _instance;

  // Variables
  late SendPort _commandPort;
  late ReceivePort _receivePort;

  static late final KafkaClient kafka;
  static late final KafkaAdmin admin;
  static late final KafkaProducer producer;
  static late final KafkaConsumer consumer;

  static List<String> topicsToConsume = [];
  static late StreamSubscription? _subscription;

  static List<Broker> _brokers = [];
  static final StreamController _eventController = StreamController();
  static final int timeoutMs = 1500;

  // static String _serialNumber = '';
  static bool _hasUpdatedTopicsOnClusterOnce = false;
  static bool _initializedAdminOnce = false;
  bool _isClosed = false;

  final Globals _globals = Globals();
  final Map<int, Completer> _pendingRequests = {};

  final Completer<SendPort> _portCompleter = Completer<SendPort>();
  Future<SendPort> get portReady => _portCompleter.future;

  // Getters
  static Stream get eventStream => _eventController.stream.asBroadcastStream();
  bool get isAbleToFetch => _hasUpdatedTopicsOnClusterOnce;

  factory KafkaGateway({required List<Broker> brokers}) {
    _instance ??= KafkaGateway._(brokers: brokers);
    return _instance!;
  }

  KafkaGateway._({required List<Broker> brokers}) {
    _brokers = brokers;
  }

  // Isolate Mathods
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

    List<Map<String, dynamic>> brokers =
        EntityConversorFactory.convertBrokerListToMapList(brokers: _brokers);

    try {
      await FlutterIsolate.spawn(_startKafkaIsolate, [
        initPort.sendPort,
        brokers,
        _globals.topics,
      ]);
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    _receivePort = receivePort;
    _receivePort.listen((message) => _handleResponseFromKafka(message));
    _commandPort = await portReady;
  }

  @pragma('vm:entry-point')
  static void _startKafkaIsolate(List params) {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final SendPort sendPort = params[0] as SendPort;
    final List<Map<String, dynamic>> brokersDto = params[1];
    final List<String> topics = params[2] as List<String>;

    final List<Broker> brokers =
        EntityConversorFactory.convertMapListToBrokerList(dto: brokersDto);

    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _kafkaCommandHandler(receivePort, sendPort, brokers, topics);
  }

  static Future<void> _kafkaCommandHandler(
    ReceivePort receivePort,
    SendPort sendPort,
    List<Broker> brokers,
    List<String> topics,
  ) async {
    kafka = KafkaClient(
      brokers: brokers,
      sessionTimeoutMs: 1800000,
      rebalanceTimeoutMs: 1500,
    );

    // Needed for it is another Isolate
    topicsToConsume = topics;

    await initialize();

    final commandPort = ReceivePort();
    sendPort.send(commandPort.sendPort);

    eventStream.listen((event) {
      // print("{KAFKA-GATEWAY} Received event: $event");
      sendPort.send(event.toJson());
    });

    await for (final message in commandPort) {
      final String context = message['context'];
      IKafkaRequest? dto;

      switch (context) {
        case 'fetch':
          dto = KafkaFetchRequestDto.fromMap(message);
          break;
        case 'produce':
          dto = KafkaProduceRequestDto.fromMap(message);
          break;
        case 'admin':
          break;
      }

      if (dto == null) return;

      if (dto.isShutdown) {
        await kafka.close();
        commandPort.close();
        break;
      }

      if (dto is KafkaProduceRequestDto) {
        await producer.produce(
          acks: dto.acks,
          timeoutMs: timeoutMs,
          topics: dto.topics,
          producerId: dto.producerId,
          async: dto.async,
          apiVersion: dto.apiVersion,
        );
      }

      if (dto is KafkaFetchRequestDto) {
        await consumer.sendFetchRequest(
          isolationLevel: dto.isolationLevel,
          apiVersion: dto.apiVersion,
          async: dto.async,
          topics: dto.topics,
        );
      }
    }
  }

  void _handleResponseFromKafka(dynamic message) {
    if (message is SendPort) {
      if (_portCompleter.isCompleted) return;

      _portCompleter.complete(message);

      return;
    }

    final dynamic decodedRes = EntityConversorFactory.convertFromKafkaResponse(
      message,
    );

    if (decodedRes is FetchResponse?) {
      KafkaEventHandler.handleEvent(res: decodedRes);
    }

    if (_isClosed && _pendingRequests.isEmpty) _receivePort.close();
  }

  Future<Object?> execute({required IKafkaRequest req}) {
    final Completer completer = Completer<Object?>();
    _pendingRequests[req.id] = completer;
    _commandPort.send(req.toMap());
    return completer.future;
  }

  // Methods
  static Future<void> connect() async {
    if (kafka.isKafkaStarted) return;
    await kafka.connect();

    Future.microtask(() {
      _subscription = kafka.eventStream.listen(
        (event) => _eventController.add(event),
      );
    });
  }

  static Future<void> initKafkaAdmin() async {
    if (!_initializedAdminOnce) {
      admin = kafka.getAdminClient();
      _initializedAdminOnce = true;
    }

    if (!_hasUpdatedTopicsOnClusterOnce) {
      await admin.updateTopicsMetadata(
        topics: topicsToConsume,
        apiVersion: 9,
        allowAutoTopicCreation: true,
        includeClusterAuthorizedOperations: false,
        includeTopicAuthorizedOperations: false,
        correlationId: null,
      );

      _hasUpdatedTopicsOnClusterOnce = true;
    }
  }

  static Future<void> initKafkaProducer() async {
    if (kafka.isProducerStarted) return;
    producer = kafka.getProducerClient();
  }

  static Future<void> initKafkaConsumer() async {
    if (kafka.isConsumerStarted) return;
    consumer = kafka.getConsumerClient();
  }

  static Future<void> initialize() async {
    await connect();
    await initKafkaAdmin();
    await initKafkaProducer();
    await initKafkaConsumer();
  }

  Future<void> close() async {
    await kafka.close();
    await _eventController.close();
    await _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    if (_isClosed) return;
    _isClosed = true;
    _commandPort.send(IKafkaRequest.shutdown());
  }
}
