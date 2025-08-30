import 'package:get_it/get_it.dart';
import 'package:picnic/services/picnic_service.dart';

import 'picnic_participant_service.dart';
import 'chat_service.dart';

final getIt = GetIt.instance;

void setupServices() {
  getIt.registerLazySingleton<ChatService>(() => ChatService());
  getIt.registerLazySingleton<PicnicParticipantService>(()=> PicnicParticipantService());
  getIt.registerLazySingleton<PicnicService>(() => PicnicService());
}