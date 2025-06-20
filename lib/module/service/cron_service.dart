import 'package:cron/cron.dart';
import 'package:salesforce/module/service/customer_service.dart';
import 'package:salesforce/module/service/kafka_service.dart';

class CronService {
  static CronService? _service;
  final Cron _cron = Cron();

  CronService._();

  factory CronService() {
    _service ??= CronService._();
    return _service!;
  }

  final KafkaService kafkaService = KafkaService();
  final CustomerService customerService = CustomerService();
  final Map<String, ScheduledTask> _schedules = {};

  Iterable<String> get tasks => _schedules.keys;

  // Management
  void closeService() {
    _schedules.forEach((id, task) {
      task.cancel();
    });

    _schedules.clear();
    _cron.close();
  }

  void addTask(String id, String cronExpression, Function() task) {
    if (_schedules.containsKey(id)) return;

    _schedules[id] = _cron.schedule(Schedule.parse(cronExpression), task);
  }

  void removetask(String id) {
    if (!_schedules.containsKey(id)) return;

    _schedules[id]!.cancel();
    _schedules.remove(id);
  }

  // Usable
  void startCronService() {
    addTask('kafka-fetch', '*/15 * * * * *', () => kafkaService.doFetchTask());

    addTask(
      'customer-sync',
      '20 */3 * * * *',
      () => customerService.syncAndSaveToLocal(),
    );
  }

  void kickStart() async {}
}
