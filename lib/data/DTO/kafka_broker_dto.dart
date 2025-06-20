class KafkaBrokerDto {
  final int? nodeId;
  final String host;
  final int port;
  String? rack;

  KafkaBrokerDto({
    this.nodeId,
    required this.host,
    required this.port,
    this.rack,
  });

  static KafkaBrokerDto fromMap(Map<String, dynamic> entity) {
    return KafkaBrokerDto(
      host: entity['host'],
      port: entity['port'],
      nodeId: entity['nodeId'],
      rack: entity['rack'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'host': host, 'port': port, 'nodeId': nodeId, 'rack': rack};
  }
}
