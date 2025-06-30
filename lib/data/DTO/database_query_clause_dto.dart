import 'package:salesforce/domain/enum/enum_database_query_operators.dart';

class DatabaseQueryClauseDto {
  final DatabaseQueryOperator operator;
  final dynamic value;

  DatabaseQueryClauseDto({required this.operator, required this.value});
}
