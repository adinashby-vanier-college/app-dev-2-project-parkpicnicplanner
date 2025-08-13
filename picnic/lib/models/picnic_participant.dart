import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/enums/participant_type.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

//Alias validator type
typedef _Valid = ModelValidators;

class PicnicParticipant {
  PicnicParticipant({
    required this.participantNickname,
    required this.picnicUid,
    required this.userUid,
    required this.modelRef,
    this.participantBlurb = "",
    required this.participantType
  });

  final DocumentReference modelRef;

  final String participantNickname;
  final String userUid;
  final String picnicUid;
  String participantBlurb;
  final ParticipantType participantType;

  factory PicnicParticipant.fromFirestore(Map<String, dynamic>? data, DocumentReference modelReference) {
    final errors = <String>[];

    final String? participantName = data?['participantNickname'] ?? _Valid.required(errors, 'participantNickname');
    final String? userUid = data?['userUid'] ?? _Valid.required(errors,'userUid');
    final String? picnicUid = data?['picnicUid'] ?? _Valid.required(errors,'picnicUid');

    final String participantBlurb = data?['participantBlurb'] ?? "";

    final ParticipantType? participantType = ParticipantType.fromLabel(data?['participantType']) ?? _Valid.required(errors, 'participantType');


    if (errors.isNotEmpty) {
      throw DocumentFormatException("Missing required fields");
    }

    return PicnicParticipant(
      participantNickname: participantName!,
      userUid: userUid!,
      picnicUid: picnicUid!,
      participantBlurb: participantBlurb,
      modelRef: modelReference,
        participantType: participantType!
    );
  }

}