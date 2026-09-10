import 'package:liaison_app/core/notification/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service_provider.g.dart';

@riverpod
NotificationService notificationService(Ref ref) {
  return const NoopNotificationService();
}
