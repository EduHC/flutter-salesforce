import 'package:salesforce/data/DTO/database_join_clause_dto.dart';
import 'package:salesforce/data/DTO/database_query_clause_dto.dart';
import 'package:salesforce/domain/enum/enum_database_query_operators.dart';

class DatabaseUtils {
  static DatabaseUtils? _instance;

  DatabaseUtils._();

  factory DatabaseUtils() {
    _instance ??= DatabaseUtils._();
    return _instance!;
  }

  static String buildSelectQuery(
    String tableName, {
    List<String>? columns,
    List<DatabaseJoinClauseDto>? joins,
    Map<String, DatabaseQueryClauseDto>? whereParams,
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

    if (whereParams != null) buffer.write(_buildWhereClause(whereParams));

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
    print("SQL: ${buffer.toString()}");
    return buffer.toString();
  }

  static String buildUpdateQuery(
    String tableName, {
    required Map<String, dynamic> setValues,
    required Map<String, DatabaseQueryClauseDto> whereParams,
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

    return 'UPDATE $tableName SET $setClause ${_buildWhereClause(whereParams)};';
  }

  static String buildDeleteQuery(
    String tableName, {
    required Map<String, DatabaseQueryClauseDto> whereParams,
  }) {
    if (whereParams.isEmpty) {
      throw Exception("Tried to update a table without passing where clause!");
    }

    return 'DELETE FROM $tableName ${_buildWhereClause(whereParams)};';
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

  static String _buildWhereClause(
    Map<String, DatabaseQueryClauseDto> whereParams,
  ) {
    if (whereParams.isEmpty) return '';

    final clauses = <String>[];

    for (final entry in whereParams.entries) {
      final field = entry.key;
      final operator = entry.value.operator;
      final value = entry.value.value;

      String clause;

      switch (operator) {
        case DatabaseQueryOperator.eq:
          clause = "$field = ${_formatValue(value)}";
          break;

        case DatabaseQueryOperator.diff:
          clause = "$field <> ${_formatValue(value)}";
          break;

        case DatabaseQueryOperator.like:
          clause = "$field LIKE '%${_formatValue(value)}%'";
          break;

        case DatabaseQueryOperator.notlike:
          clause = "$field NOT LIKE '%${_formatValue(value)}%'";
          break;

        case DatabaseQueryOperator.array:
          clause = _buildInClause(field, value, not: false);
          break;

        case DatabaseQueryOperator.notarray:
          clause = _buildInClause(field, value, not: true);
          break;

        case DatabaseQueryOperator.isnull:
          clause = "$field IS NULL";
          break;

        case DatabaseQueryOperator.isnotnull:
          clause = "$field IS NOT NULL";
          break;
      }

      clauses.add(clause);
    }

    return ' WHERE ${clauses.join(' AND ')} ';
  }

  static String _formatValue(dynamic val) {
    if (val == null) return 'NULL';
    if (val is String) return val.replaceAll("'", "''");
    return val.toString();
  }

  static String _buildInClause(
    String field,
    dynamic value, {
    bool not = false,
  }) {
    if (value is List && value.isNotEmpty) {
      final formattedList = value.map(_formatValue).join(', ');
      final operator = not ? 'NOT IN' : 'IN';
      return "$field $operator ($formattedList)";
    }

    return not ? '1=1' : '1=0';
  }
}
