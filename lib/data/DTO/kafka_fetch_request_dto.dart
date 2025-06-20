import 'dart:convert';

import 'package:dart_kafka/dart_kafka.dart';
import 'package:salesforce/data/DTO/kafka_request_dto.dart';
import 'package:salesforce/util/util.dart';

class KafkaFetchRequestDto<T> extends IKafkaRequest {
  final int isolationLevel;
  final int apiVersion;
  final bool async;
  final List<Topic> topics;

  KafkaFetchRequestDto({
    required this.topics,
    required super.context,
    bool isShubdown = false,
    int? id,
    this.isolationLevel = 0,
    this.apiVersion = 8,
    this.async = true,
  }) : super(id: id ?? Util.generateMsgId(), isShutdown: isShubdown);

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isolationLevel': isolationLevel,
      'apiVersion': apiVersion,
      'async': async,
      'topics': jsonEncode(topics),
      'context': context,
      'isShutdown': isShutdown,
    };
  }

  static KafkaFetchRequestDto fromMap(Map<String, dynamic> map) {
    final dto = KafkaFetchRequestDto(
      id: map['id'],
      isolationLevel: map['isolationLevel'],
      apiVersion: map['apiVersion'],
      async: map['async'],
      context: map['context'],
      topics:
          ((jsonDecode(map['topics']) ?? []) as List)
              .map((element) => Topic.fromJson(element))
              .toList(),
      isShubdown: map['isShutdown'],
    );

    return dto;
  }

  IKafkaRequest shutdown() {
    return KafkaFetchRequestDto(topics: [], context: '', isShubdown: true);
  }
}
