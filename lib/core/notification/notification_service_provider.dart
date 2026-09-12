import 'package:liaison_app/core/notification/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_service_provider.g.dart';

/// initialize() 뒤 리스너·구독이 살아 있어야 하므로 keepAlive.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  return const NoopNotificationService();
}
