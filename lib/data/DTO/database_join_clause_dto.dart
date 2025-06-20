class DatabaseJoinClauseDto {
  final String type;
  final String table;
  final String on;

  DatabaseJoinClauseDto({
    required this.type,
    required this.table,
    required this.on,
  });
}
