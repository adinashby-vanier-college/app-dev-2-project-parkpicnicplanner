import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

//Alias validator type
typedef _Valid = ModelValidators;

class Picnic {
  static String get modelName => 'Picnic';

  Picnic({
    required this.modelRef,
    required this.name,
    required this.participants
  });

  final DocumentReference modelRef;
  final String name;
  final CollectionReference participants;

  factory Picnic.fromFirestore(Map<String, dynamic>? data, DocumentReference modelReference) {
    final errors = <String>[];

    final String? name = data?['name'] ?? _Valid.required(errors, 'name');

    //subcollections are not retrieved automatically, request them if required (will generate another query)
    final CollectionReference participants = modelReference.collection("participants");

    if (errors.isNotEmpty) {
      throw DocumentFormatException("Missing [${errors.length}] required field(s) for model <${Picnic.modelName}>:\n\t ${errors.join("\n\t")}");
    }

    return Picnic(
      modelRef: modelReference,
      name: name!,
      participants: participants,
    );
  }
}