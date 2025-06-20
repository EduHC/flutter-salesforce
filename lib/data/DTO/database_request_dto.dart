import 'package:salesforce/util/util.dart';

class DatabaseRequestDto<T> {
  final int id;
  final String sql;
  final String entity;
  final bool noResult;
  final bool isShutdown;

  DatabaseRequestDto(this.sql, this.entity, this.id)
    : isShutdown = false,
      noResult = false;

  DatabaseRequestDto.shutdown()
    : sql = '',
      noResult = true,
      isShutdown = true,
      id = Util.generateMsgId(),
      entity = '';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sql': sql,
      'noResult': noResult,
      'isShutdown': isShutdown,
      'entity': entity,
    };
  }

  static DatabaseRequestDto fromMap(Map<String, dynamic> map) {
    final dto = DatabaseRequestDto(
      map['sql'] as String,
      map['entity'] as String,
      map['id'] as int,
    );
    return dto;
  }
}
