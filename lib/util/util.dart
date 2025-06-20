import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

class Util {
  static Util? _util;

  Util._();

  factory Util() {
    _util ??= Util._();
    return _util!;
  }

  static int generateMsgId() {
    final Random random = Random();
    int value = random.nextInt(1 << 32);
    return value - (1 << 31);
  }

  static bool? tryConvertToBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1 ? true : false;
    if (value is String) return bool.tryParse(value, caseSensitive: false);
    if (value is BigInt) return value == BigInt.from(1) ? true : false;
    return null;
  }

  static int? tryConvertToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is BigInt) return value.toInt();
    return null;
  }

  Future<File> createResetScript() async {
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/update.sh');
    final String content = '''
        #!/system/bin/sh
        sleep 2
        reboot
    ''';

    await file
        .writeAsString(content, mode: FileMode.write, flush: true)
        .catchError((e) => throw Exception('Write failed: $e'));

    await Process.run('chmod', ['777', file.path]);
    return file;
  }

  String kafkaDefineSensorLevelStr({required int level}) {
    if (level == 11) return 'Error';
    if (level == 10) return 'Warning';
    return 'Normal';
  }

  static String formatDateToApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String calculateListHash(List content) {
    final jsonString = json.encode(content);
    return sha256.convert(utf8.encode(jsonString)).toString();
  }

  static DateTime convertToDateTime(dynamic date) {
    if (date is DateTime) return date;
    return DateTime.parse(date);
  }

  static DateTime? convertToNullableDateTime(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    return DateTime.parse(date);
  }
}
