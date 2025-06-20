import 'package:salesforce/data/DTO/kafka_request_dto.dart';
import 'package:salesforce/data/gateway/kafka_gateway.dart';

class KafkaRepository {
  static KafkaRepository? _instance;

  KafkaRepository._();

  factory KafkaRepository() {
    _instance ??= KafkaRepository._();
    return _instance!;
  }

  final KafkaGateway _gateway = KafkaGateway(brokers: []);

  Future<Object?> execute({required IKafkaRequest req}) async {
    return await _gateway.execute(req: req);
  }
}
