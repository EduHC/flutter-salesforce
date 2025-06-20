import 'package:salesforce/data/DTO/database_join_clause_dto.dart';

class DatabaseUtils {
  static DatabaseUtils? _utils;

  DatabaseUtils._();

  factory DatabaseUtils() {
    _utils ??= DatabaseUtils._();
    return _utils!;
  }

  static String buildSelectQuery(
    String tableName, {
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, dynamic>? whereParams,
    List<String>? orderBy,
    int? limit,
    int? offset,
  }) {
    final selected =
        (columns != null && columns.isNotEmpty) ? columns.join(', ') : '*';
    final buffer = StringBuffer('SELECT $selected FROM $tableName');

    for (var j in joins ?? []) {
      final type = j.type.toUpperCase();
      buffer.write(' $type JOIN ${j.table} ON ${j.on}');
    }

    if (whereParams != null && whereParams.isNotEmpty) {
      final whereClause = whereParams.entries
          .map((e) {
            final key = e.key;
            final val = e.value;
            final formatted =
                val == null
                    ? 'NULL'
                    : (val is String
                        ? "'${val.replaceAll("'", "''")}'"
                        : val.toString());
            return '$key = $formatted';
          })
          .join(' AND ');
      buffer.write(' WHERE $whereClause');
    }

    if (orderBy != null && orderBy.isNotEmpty) {
      buffer.write(' ORDER BY ${orderBy.join(', ')}');
    }

    if (limit != null) {
      buffer.write(' LIMIT $limit');
    }

    if (offset != null) {
      buffer.write(' OFFSET $offset');
    }

    buffer.write(';');
    return buffer.toString();
  }

  static String buildUpdateQuery(
    String tableName, {
    required Map<String, dynamic> setValues,
    required Map<String, dynamic> whereParams,
  }) {
    if (setValues.isEmpty) {
      throw Exception(
        "Tried to update a table without passing set values clause!",
      );
    }

    if (whereParams.isEmpty) {
      throw Exception("Tried to update a table without passing where clause!");
    }

    final setClause = setValues.entries
        .map((entry) {
          final key = entry.key;
          final value = entry.value;
          final formattedValue =
              value is String
                  ? "'${value.replaceAll("'", "''")}'"
                  : value.toString();
          return '$key = $formattedValue';
        })
        .join(', ');

    final whereClause = whereParams.entries
        .map((entry) {
          final key = entry.key;
          final value = entry.value;
          final formattedValue =
              value is String
                  ? "'${value.replaceAll("'", "''")}'"
                  : value.toString();
          return '$key = $formattedValue';
        })
        .join(' AND ');

    return 'UPDATE $tableName SET $setClause WHERE $whereClause;';
  }

  static String buildDeleteQuery(
    String tableName, {
    required Map<String, dynamic> whereParams,
  }) {
    if (whereParams.isEmpty) {
      throw Exception("Tried to update a table without passing where clause!");
    }

    final whereClause = whereParams.entries
        .map((entry) {
          final key = entry.key;
          final value = entry.value;
          final formattedValue =
              value is String
                  ? "'${value.replaceAll("'", "''")}'"
                  : value.toString();
          return '$key = $formattedValue';
        })
        .join(' AND ');

    return 'DELETE FROM $tableName WHERE $whereClause;';
  }

  static String buildInsertQuery(
    String tableName, {
    required Map<String, dynamic> values,
  }) {
    if (values.isEmpty) {
      throw Exception(
        "Tried to insert into a table without passing any values!",
      );
    }

    final columns = values.keys.join(', ');

    final formattedValues = values.values
        .map((value) {
          if (value is String) {
            final escaped = value.replaceAll("'", "''");
            return "'$escaped'";
          } else if (value == null) {
            return 'NULL';
          } else {
            return value.toString();
          }
        })
        .join(', ');

    return 'INSERT OR IGNORE INTO $tableName ($columns) VALUES ($formattedValues);';
  }
}
