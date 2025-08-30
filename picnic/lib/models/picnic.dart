import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:picnic/exceptions/document_format_exception.dart';
import 'package:picnic/validators/model_validators.dart';

//Alias validator type
typedef _Valid = ModelValidators;

class Picnic {
  static String get modelName => 'Picnic';

  Picnic({
    this.modelRef,
    required this.name,
    this.description = "",
    this.participants,
    this.createdAt,
    this.updatedAt,
    this.scheduledAt,
  });

  final DocumentReference? modelRef;
  final String name;
  final String description;
  final CollectionReference? participants;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? scheduledAt;

  factory Picnic.fromFirestore(
    Map<String, dynamic>? data,
    DocumentReference modelReference,
  ) {
    final errors = <String>[];

    final String? name = data?['name'] ?? _Valid.required(errors, 'name');
    final String description = data?['description'] ?? "";

    final DateTime? scheduledAt = data?['scheduledAt'];

    final DateTime? createdAt = data?['createdAt'] ?? _Valid.required(errors, 'createdAt');
    final DateTime? updatedAt = data?['updatedAt'] ?? _Valid.required(errors, 'updatedAt');

    //subcollections are not retrieved automatically, request them if required (will generate another query)
    final CollectionReference participants = modelReference.collection(
      "participants",
    );

    if (errors.isNotEmpty) {
      throw DocumentFormatException(
        "Missing [${errors.length}] required field(s) for model <${Picnic.modelName}>:\n\t ${errors.join("\n\t")}",
      );
    }

    return Picnic(
      modelRef: modelReference,
      name: name!,
      description: description,
      participants: participants,
      createdAt: createdAt,
      updatedAt: updatedAt,
      scheduledAt: scheduledAt,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    String id =
        modelRef?.id ??
        (FirebaseFirestore.instance.collection('picnics').doc().id); //Generate one on the server and retrieve

    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      if (participants != null) 'participants': participants,
    };
  }
}
