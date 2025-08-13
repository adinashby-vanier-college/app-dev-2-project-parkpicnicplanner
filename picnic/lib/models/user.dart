import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final bool isPrivate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.bio,
    this.isPrivate = false,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? name,
    String? email,
    String? profileImageUrl,
    String? bio,
    bool? isPrivate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'isPrivate': isPrivate,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert to Map for updating existing Firestore documents (preserves existing structure)
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'isPrivate': isPrivate,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? map['uid'] ?? '',  // Handle both 'id' and 'uid' fields
      name: map['name'] ?? _buildFullName(map['firstName'], map['lastName']),  // Handle both formats
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      isPrivate: map['isPrivate'] ?? false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  // Create from Firestore DocumentSnapshot
  factory User.fromFirestore(Map<String, dynamic> data, String documentId) {
    return User.fromMap({...data, 'id': documentId});
  }

  // Helper method to build full name from firstName and lastName
  static String _buildFullName(dynamic firstName, dynamic lastName) {
    final first = firstName?.toString() ?? '';
    final last = lastName?.toString() ?? '';

    if (first.isEmpty && last.isEmpty) {
      return 'Anonymous User';
    } else if (first.isEmpty) {
      return last;
    } else if (last.isEmpty) {
      return first;
    } else {
      return '$first $last';
    }
  }

  // Helper method to parse DateTime from various formats
  static DateTime? _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return null;

    // Handle Firestore Timestamp
    if (dateTime.runtimeType.toString() == 'Timestamp') {
      return (dateTime as dynamic).toDate();
    }

    // Handle ISO8601 String
    if (dateTime is String) {
      try {
        return DateTime.parse(dateTime);
      } catch (e) {
        return null;
      }
    }

    // Handle DateTime object
    if (dateTime is DateTime) {
      return dateTime;
    }

    return null;
  }
}