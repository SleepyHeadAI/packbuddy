import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a suggestion or feedback item submitted by a user
class UserFeedback {
  final String id;
  final String userId;
  final String userEmail;
  final String message;
  final String? imageBase64;
  final String? localImagePath;
  final DateTime createdAt;
  final String status; // 'new', 'reviewed', 'archived'

  const UserFeedback({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.message,
    this.imageBase64,
    this.localImagePath,
    required this.createdAt,
    this.status = 'new',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_email': userEmail,
      'message': message,
      if (imageBase64 != null) 'image_base64': imageBase64,
      if (localImagePath != null) 'local_image_path': localImagePath,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory UserFeedback.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parsedDate;
    final createdRaw = map['created_at'];
    if (createdRaw is Timestamp) {
      parsedDate = createdRaw.toDate();
    } else if (createdRaw is String) {
      parsedDate = DateTime.tryParse(createdRaw) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return UserFeedback(
      id: docId ?? map['id'] ?? '',
      userId: map['user_id'] ?? map['userId'] ?? '',
      userEmail: map['user_email'] ?? map['userEmail'] ?? 'Anonim',
      message: map['message'] ?? '',
      imageBase64: map['image_base64'] ?? map['imageBase64'],
      localImagePath: map['local_image_path'] ?? map['localImagePath'],
      createdAt: parsedDate,
      status: map['status'] ?? 'new',
    );
  }

  UserFeedback copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? message,
    String? imageBase64,
    String? localImagePath,
    DateTime? createdAt,
    String? status,
  }) {
    return UserFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      message: message ?? this.message,
      imageBase64: imageBase64 ?? this.imageBase64,
      localImagePath: localImagePath ?? this.localImagePath,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}

