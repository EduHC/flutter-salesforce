// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:salesforce/domain/model/abstract_entity.dart';

class KafkaTopicOffset extends AbstractEntity {
  final String topicName;
  final int partition;
  final int offset;

  KafkaTopicOffset(
    super.id, {
    required this.topicName,
    required this.partition,
    required this.offset,
  });

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'topicName': topicName,
      'partition': partition,
      'offset': offset,
    };
  }

  KafkaTopicOffset copyWith({String? topicName, int? partition, int? offset}) {
    return KafkaTopicOffset(
      id,
      topicName: topicName ?? this.topicName,
      partition: partition ?? this.partition,
      offset: offset ?? this.offset,
    );
  }

  factory KafkaTopicOffset.fromMap(Map<String, dynamic> map) {
    return KafkaTopicOffset(
      map['id'] as int,
      topicName: map['topicName'] as String,
      partition: map['partition'] as int,
      offset: map['offset'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory KafkaTopicOffset.fromJson(String source) =>
      KafkaTopicOffset.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'KafkaTopicOffset(id: $id, topicName: $topicName, partition: $partition, offset: $offset)';

  @override
  bool operator ==(covariant KafkaTopicOffset other) {
    if (identical(this, other)) return true;

    return other.topicName == topicName &&
        other.partition == partition &&
        other.offset == offset;
  }

  @override
  int get hashCode => topicName.hashCode ^ partition.hashCode ^ offset.hashCode;
}
