/// Domain entity representing a travel document stored in the Document Vault
class Document {
  final String id;
  final String title;
  final String category;
  final String? subCategory;
  final String localImagePath;
  final String? tripId;
  final String? fileType;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Document({
    required this.id,
    required this.title,
    required this.category,
    this.subCategory,
    required this.localImagePath,
    this.tripId,
    this.fileType,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Helper boolean to check if document is a PDF
  bool get isPdf =>
      (fileType?.toLowerCase() == 'pdf') ||
      localImagePath.toLowerCase().endsWith('.pdf');

  /// Creates a copy with optionally modified fields
  Document copyWith({
    String? id,
    String? title,
    String? category,
    String? subCategory,
    bool clearSubCategory = false,
    String? localImagePath,
    String? tripId,
    bool clearTripId = false,
    String? fileType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      subCategory: clearSubCategory ? null : (subCategory ?? this.subCategory),
      localImagePath: localImagePath ?? this.localImagePath,
      tripId: clearTripId ? null : (tripId ?? this.tripId),
      fileType: fileType ?? this.fileType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Serialization for Cloud Firestore / JSON APIs
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'subCategory': subCategory,
      'localImagePath': localImagePath,
      'tripId': tripId,
      'fileType': fileType ?? (isPdf ? 'pdf' : 'image'),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Deserialization from Cloud Firestore / JSON APIs
  factory Document.fromJson(Map<String, dynamic> json) {
    final localPath = (json['localImagePath'] ?? '') as String;
    final fType = (json['fileType'] as String?) ??
        (localPath.toLowerCase().endsWith('.pdf') ? 'pdf' : 'image');

    return Document(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String? ?? 'Other',
      subCategory: (json['subCategory'] ?? json['sub_category']) as String?,
      localImagePath: localPath,
      tripId: json['tripId'] as String?,
      fileType: fType,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  /// Serialization for local SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'sub_category': subCategory,
      'local_image_path': localImagePath,
      'trip_id': tripId,
      'file_type': fileType ?? (isPdf ? 'pdf' : 'image'),
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Deserialization from local SQLite database
  factory Document.fromMap(Map<String, dynamic> map) {
    final localPath = (map['local_image_path'] ?? map['file_path'] ?? '') as String;
    final fType = (map['file_type'] ?? map['fileType'] as String?) ??
        (localPath.toLowerCase().endsWith('.pdf') ? 'pdf' : 'image');

    return Document(
      id: map['id'] as String,
      title: map['title'] as String,
      category: map['category'] as String? ?? 'Other',
      subCategory: (map['sub_category'] ?? map['subCategory']) as String?,
      localImagePath: localPath,
      tripId: (map['trip_id'] ?? map['tripId']) as String?,
      fileType: fType,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }
}
