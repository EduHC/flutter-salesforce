import 'dart:convert';

import 'package:dart_kafka/dart_kafka.dart';
import 'package:salesforce/data/DTO/kafka_request_dto.dart';
import 'package:salesforce/util/util.dart';

class KafkaProduceRequestDto<T> extends IKafkaRequest {
  final int acks;
  final int apiVersion;
  final bool async;
  final int producerId;
  final List<Topic> topics;

  KafkaProduceRequestDto({
    required this.topics,
    required super.context,
    bool isShubdown = false,
    int? id,
    this.acks = -1,
    this.apiVersion = 11,
    this.async = true,
    this.producerId = -1,
  }) : super(id: id ?? Util.generateMsgId(), isShutdown: isShubdown);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'acks': acks,
      'apiVersion': apiVersion,
      'async': async,
      'producerId': producerId,
      'topics': jsonEncode(topics),
      'context': context,
      'isShutdown': isShutdown,
    };
  }

  static KafkaProduceRequestDto fromMap(Map<String, dynamic> map) {
    final dto = KafkaProduceRequestDto(
      id: map['id'],
      acks: map['acks'],
      apiVersion: map['apiVersion'],
      async: map['async'],
      producerId: map['producerId'],
      topics:
          ((jsonDecode(map['topics']) ?? []) as List)
              .map((element) => Topic.fromJson(element))
              .toList(),
      context: map['context'],
      isShubdown: map['isShutdown'],
    );

    return dto;
  }

  IKafkaRequest shutdown() {
    return KafkaProduceRequestDto(topics: [], context: '', isShubdown: true);
  }
}
