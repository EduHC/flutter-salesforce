import 'dart:isolate';
import 'dart:ui';

// import 'package:dart_kafka/dart_kafka.dart';
import 'package:flutter/material.dart';
import 'package:salesforce/data/gateway/database_gateway.dart';
import 'package:salesforce/data/gateway/http_gateway.dart';
// import 'package:salesforce/data/gateway/file_gateway.dart';
// import 'package:salesforce/data/gateway/kafka_gateway.dart';
// import 'package:salesforce/data/gateway/serial_gateway.dart';
import 'package:salesforce/globals.dart';
// import 'package:salesforce/module/service/cron_service.dart';

class Setup {
  static doInitialTasks() async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final Globals globals = Globals();
    globals.token = RootIsolateToken.instance!;

    // Initialize Gateways and its Isolates
    try {
      final DatabaseGateway databaseGateway = DatabaseGateway();
      await databaseGateway.spawn();

      globals.topics = ["control", "status", "clean", "reset", "api_logs"];

      // final String kafkaServer = 'localhost:2020';
      // final List<Broker> brokers = [
      //   Broker(host: kafkaServer, port: 29092),
      //   Broker(host: kafkaServer, port: 29093),
      //   Broker(host: kafkaServer, port: 29094),
      // ];
      // final KafkaGateway kafkaGateway = KafkaGateway(brokers: brokers);
      // await kafkaGateway.spawn();

      final HttpGateway httpGateway = HttpGateway();
      await httpGateway.spawn();

      // final FileGateway fileGateway = FileGateway();
      // final SerialGateway serialGateway = SerialGateway();

      // Services
      // CronService cronService = CronService();
      // cronService.startCronService();
    } on RemoteError catch (e) {
      globals.hasError = true;
      globals.errorMsg = e.toString();
    } on Exception catch (e) {
      globals.hasError = true;
      globals.errorMsg = e.toString();
    }
  }
}
