import 'package:salesforce/data/DTO/kafka_fetch_request_dto.dart';

abstract class IKafkaRequest {
  final int id;
  final bool isShutdown;
  final String context;

  IKafkaRequest({
    required this.id,
    required this.isShutdown,
    required this.context,
  });

  Map<String, dynamic> toMap();

  static IKafkaRequest shutdown() {
    return KafkaFetchRequestDto(topics: [], context: '', isShubdown: true);
  }
}
