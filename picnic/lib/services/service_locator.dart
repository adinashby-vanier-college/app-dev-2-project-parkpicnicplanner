import 'package:get_it/get_it.dart';

import 'chat_service.dart';
final getIt = GetIt.instance;

void setupServices() {
  getIt.registerLazySingleton<ChatService>(() => ChatService());
}