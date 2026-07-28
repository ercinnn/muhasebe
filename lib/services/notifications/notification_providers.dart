import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/settings/data/settings_repository.dart';
import 'notification_service.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) =>
    NotificationServiceImpl(ref.watch(settingsRepositoryProvider));
