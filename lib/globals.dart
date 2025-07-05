import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

class Globals {
  static Globals? _globals;

  Globals._();

  factory Globals() {
    _globals ??= Globals._();
    return _globals!;
  }

  RootIsolateToken? token;
  List<String> topics = [];
  PersistentTabController tabController = PersistentTabController(
    initialIndex: 0,
  );

  bool hasError = false;
  String? errorMsg;
}
