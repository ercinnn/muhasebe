import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'notification_service.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) => NotificationServiceImpl();
