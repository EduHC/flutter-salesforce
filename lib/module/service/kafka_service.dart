import 'package:dart_kafka/dart_kafka.dart';
import 'package:salesforce/data/DTO/database_query_clause_dto.dart';
import 'package:salesforce/data/DTO/kafka_fetch_request_dto.dart';
import 'package:salesforce/data/DTO/kafka_produce_request_dto.dart';
import 'package:salesforce/data/repository/kafka/kafka_repository.dart';
import 'package:salesforce/domain/enum/enum_database_query_operators.dart';
import 'package:salesforce/domain/model/kafka_topic_offset.dart';
import 'package:salesforce/globals.dart';
import 'package:salesforce/module/service/kafka_topic_offset_service.dart';

class KafkaService {
  static KafkaService? _service;

  KafkaService._();

  factory KafkaService() {
    _service ??= KafkaService._();
    return _service!;
  }

  final Globals globals = Globals();
  final KafkaRepository kafkaRepository = KafkaRepository();
  final KafkaTopicOffsetService offsetService = KafkaTopicOffsetService();

  Future<void> fetch({required List<Topic> topics}) async {
    await kafkaRepository.execute(
      req: KafkaFetchRequestDto(context: 'fetch', topics: topics),
    );
  }

  Future<void> produce({required List<Topic> topics}) async {
    await kafkaRepository.execute(
      req: KafkaProduceRequestDto(topics: topics, context: 'produce'),
    );
  }

  Future<void> doFetchTask() async {
    final List<Future> requests = [];

    final List<String> topicsToConsume = globals.topics;
    topicsToConsume.removeWhere((element) => element.contains(RegExp('log')));

    for (String topic in topicsToConsume) {
      requests.add(_sendFetchRequest(topic: topic));
    }

    Future.wait(requests);
  }

  Future<dynamic> _sendFetchRequest({
    required String topic,
    int? offset,
    int? partitionId,
  }) async {
    List<Partition> partitions = [];
    List<KafkaTopicOffset> partitionsOffset = [];

    if (offset == null) {
      partitionsOffset = await offsetService.list(
        whereParams: {
          'topicName': DatabaseQueryClauseDto(
            operator: DatabaseQueryOperator.eq,
            value: topic,
          ),
        },
      );
    }

    if (partitionsOffset.isEmpty && offset == null) {
      await offsetService.insert(
        entity: KafkaTopicOffset(
          null,
          topicName: topic,
          partition: 0,
          offset: 0,
        ),
      );

      partitionsOffset = await offsetService.list(
        whereParams: {
          'topicName': DatabaseQueryClauseDto(
            operator: DatabaseQueryOperator.eq,
            value: topic,
          ),
        },
      );
    }

    partitions =
        partitionsOffset.map((element) {
          return Partition(id: element.partition, fetchOffset: element.offset);
        }).toList();

    if (partitions.isEmpty) {
      partitions.add(Partition(id: partitionId!, fetchOffset: offset));
    }

    await fetch(topics: [Topic(topicName: topic, partitions: partitions)]);
  }
}
