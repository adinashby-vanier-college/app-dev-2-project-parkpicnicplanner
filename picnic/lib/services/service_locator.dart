import 'package:get_it/get_it.dart';

import 'picnic_participant_service.dart';
import 'chat_service.dart';

final getIt = GetIt.instance;

void setupServices() {
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<PicnicParticipantService>(()=> PicnicParticipantService());
}