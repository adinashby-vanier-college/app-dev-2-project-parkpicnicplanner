import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/enums/participant_type.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

//Alias validator type
typedef _Valid = ModelValidators;

class PicnicParticipant {
  static String get modelName => 'PicnicParticipant';

  PicnicParticipant({
    required this.persisted,
    required this.participantNickname,
    required this.userUid,
    this.modelRef,
    this.participantBlurb = "",
    required this.participantType
  });

  final DocumentReference? modelRef;
  final bool persisted;

  final String userUid;
  final String participantNickname;
  String participantBlurb;
  final ParticipantType participantType;

  factory PicnicParticipant.fromFirestore(DocumentSnapshot doc) {
    return PicnicParticipant.fromMap(doc.data() as Map<String, dynamic>?, dbOrigin: true, modelRef: doc.reference);
  }

  factory PicnicParticipant.fromMap(Map<String,dynamic>? data, {bool dbOrigin=false, DocumentReference? modelRef}){
    final errors = <String>[];


    final String? participantName = data?['participantNickname'] ?? _Valid.required(errors, 'participantNickname');
    final String? userUid = data?['userUid'] ?? _Valid.required(errors,'userUid');
    final String participantBlurb = data?['participantBlurb'] ?? "";

    final ParticipantType? participantType;

    if (!dbOrigin) {
      participantType = ParticipantType.fromLabel(data?['participantType']) ??
          ParticipantType.active;
    } else {
      participantType = ParticipantType.fromLabel(data?['participantType']) ?? _Valid.required(errors, 'participantType');
    }

    if (errors.isNotEmpty) {
      throw DocumentFormatException("Missing [${errors.length}] required field(s) for model <${PicnicParticipant.modelName}>:\n\t ${errors.join("\n\t")}");
    }

    return PicnicParticipant(
      persisted: dbOrigin,
      participantNickname: participantName!,
      userUid: userUid!,
      participantBlurb: participantBlurb,
      modelRef: modelRef,
      participantType: participantType!,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userUid': userUid,
      'participantNickname': participantNickname,
      'participantBlurb': participantBlurb,
      'participantType': participantType.label
    };
  }

}