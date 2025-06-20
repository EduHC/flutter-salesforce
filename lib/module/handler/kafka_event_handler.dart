import 'dart:convert';

import 'package:dart_kafka/dart_kafka.dart';
import 'package:flutter/rendering.dart';
import 'package:salesforce/domain/model/kafka_topic_offset.dart';
import 'package:salesforce/module/service/kafka_service.dart';
import 'package:salesforce/module/service/kafka_topic_offset_service.dart';

class KafkaEventHandler {
  static KafkaEventHandler? _instance;

  KafkaEventHandler._();

  factory KafkaEventHandler() {
    _instance ??= KafkaEventHandler._();
    return _instance!;
  }

  static final KafkaService _kafkaService = KafkaService();
  static final KafkaTopicOffsetService _offsetService =
      KafkaTopicOffsetService();

  static Future<void> handleEvent({required FetchResponse? res}) async {
    if (res == null) return;

    for (int i = 0; i < res.topics.length; i++) {
      Topic tCurrent = res.topics[i];
      List<Map<String, int>> partitionsWithOffsetsToFetch = [];

      for (int i = 0; i < (tCurrent.partitions?.length ?? 0); i++) {
        Partition pCurrent = tCurrent.partitions![i];

        if (pCurrent.batch == null) continue;
        if (pCurrent.batch?.records == null) continue;

        bool isFinalOffset =
            (pCurrent.highWatermark! - 1) == pCurrent.batch!.baseOffset!;

        if (isFinalOffset) {
          await _offsetService.update(
            entity: KafkaTopicOffset(
              null,
              topicName: tCurrent.topicName,
              partition: pCurrent.id,
              offset: (pCurrent.batch!.baseOffset! + 1),
            ),
          );
        } else {
          partitionsWithOffsetsToFetch.add({
            'offset': (pCurrent.batch!.baseOffset! + 1),
            'partition': pCurrent.id,
          });
        }

        for (Record record in pCurrent.batch!.records!) {
          Map headers = {
            for (RecordHeader header in record.headers ?? [])
              header.key: header.value,
          };

          if (headers['origin'] == null || headers['origin'] == 'machine') {
            continue;
          }

          Map<String, dynamic> reqBody = {};
          if (record.value != null && record.value!.isNotEmpty) {
            reqBody = jsonDecode(record.value ?? '{}');
          }

          // if ("${kafka.serialNumber}.location" == tCurrent.topicName) {
          //   await _handleLocation(
          //     topic: tCurrent,
          //     partitionId: pCurrent.id,
          //     reqBody: reqBody,
          //   );
          // }
          if ("status" == tCurrent.topicName) {
            await _handleStatus(
              topic: tCurrent,
              partitionId: pCurrent.id,
              reqBody: reqBody,
            );
          }
          // if ("${kafka.serialNumber}.sensors" == tCurrent.topicName) {
          //   await _handleSensors(
          //     topic: tCurrent,
          //     partitionId: pCurrent.id,
          //     reqBody: reqBody,
          //   );
          // }
          // if ("${kafka.serialNumber}.api_logs" == tCurrent.topicName) {
          //   await _handleApiLogs(
          //     topic: tCurrent,
          //     partitionId: pCurrent.id,
          //     reqBody: reqBody,
          //   );
          // }
          // if ("${kafka.serialNumber}.machine_logs" == tCurrent.topicName) {
          //   await _handleMachineLogs(
          //     topic: tCurrent,
          //     partitionId: pCurrent.id,
          //     reqBody: reqBody,
          //   );
          // }
          if ("machine_config" == tCurrent.topicName) {
            await _handleMachineConfig(
              topic: tCurrent,
              partitionId: pCurrent.id,
              reqBody: reqBody,
              context: 'config',
            );
          }
          // if ("${kafka.serialNumber}.control" == tCurrent.topicName) {
          //   await _handleMachineConfig(
          //     topic: tCurrent,
          //     partitionId: pCurrent.id,
          //     reqBody: reqBody,
          //     context: 'control',
          //   );
          // }
          // if ("${kafka.serialNumber}.control_key" == tCurrent.topicName) {
          //   await _handleMachineConfig(
          //     topic: tCurrent,
          //     partitionId: pCurrent.id,
          //     reqBody: reqBody,
          //     context: 'control-key',
          //   );
          // }
          // if ("${kafka.serialNumber}.clean" == tCurrent.topicName) {
          //   await _handleClean(
          //     topic: tCurrent,
          //     partitionId: pCurrent.id,
          //     reqBody: reqBody,
          //   );
          // }
          // if ("${kafka.serialNumber}.reset" == tCurrent.topicName) {
          //   await _handleReset(
          //     topic: tCurrent,
          //     partitionId: pCurrent.id,
          //     reqBody: reqBody,
          //   );
          // }
        }
      }

      // for (Map<String, int> partitionOffset in partitionsWithOffsetsToFetch) {
      //   getIt<KafkaService>().doFetchTopic(
      //     topic: tCurrent.topicName,
      //     offset: partitionOffset['offset']!,
      //     partitionId: partitionOffset['partition']!,
      //   );
      // }

      // if (partitionsWithOffsetsToFetch.isEmpty) {
      //   getIt<KafkaService>().setTopicFetchAsCompleted(
      //     topic: tCurrent.topicName,
      //   );
      // }
    }
  }

  static Future<void> _handleStatus({
    required Topic topic,
    required Map<String, dynamic> reqBody,
    required int partitionId,
  }) async {
    // AppointmentConfigurationViewmodel appointment =
    //     getIt<AppointmentConfigurationViewmodel>();

    // TODO: Add a control to know if the machine is being used in long term
    Map<String, String> body = {'status': 'Paused'};

    _kafkaService.produce(
      topics: [
        Topic(
          topicName: topic.topicName,
          partitions: [
            Partition(
              id: partitionId,
              batch: RecordBatch(
                producerId: null,
                records: [
                  Record(
                    attributes: 0,
                    timestampDelta: 0,
                    offsetDelta: 0,
                    timestamp: DateTime.now().millisecondsSinceEpoch,
                    value: json.encode(body),
                    headers: [RecordHeader(key: 'origin', value: 'salesforce')],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> _handleMachineConfig({
    required Topic topic,
    required Map<String, dynamic> reqBody,
    required int partitionId,
    required String context,
  }) async {
    debugPrint("[KAFKA-EVENT-HANDLER] Handle Machine Config");
    // debugPrint("$topic");
  }
}
