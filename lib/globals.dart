import 'package:flutter/services.dart';

class Globals {
  static Globals? _globals;

  Globals._();

  factory Globals() {
    _globals ??= Globals._();
    return _globals!;
  }

  RootIsolateToken? token;
  List<String> topics = [];

  bool hasError = false;
  String? errorMsg;
}
