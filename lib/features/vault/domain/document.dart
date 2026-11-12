/// Domain entity representing a travel document stored in the Document Vault
class Document {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String? subCategory;
  final String localImagePath;
  final String? tripId;
  final String? fileType;
  final String? notes;
  final int fileSizeBytes;
  final String? cloudDataBase64;
  final String? fileExtension;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Document({
    required this.id,
    this.userId = '',
    required this.title,
    required this.category,
    this.subCategory,
    required this.localImagePath,
    this.tripId,
    this.fileType,
    this.notes,
    this.fileSizeBytes = 0,
    this.cloudDataBase64,
    this.fileExtension,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Helper boolean to check if document is a PDF
  bool get isPdf =>
      (fileType?.toLowerCase() == 'pdf') ||
      (fileExtension?.toLowerCase() == 'pdf') ||
      localImagePath.toLowerCase().endsWith('.pdf');

  /// Helper boolean to check if document belongs to Private Safe / Private Photos
  bool get isPrivate {
    final cat = category.toLowerCase().trim();
    final t = title.toLowerCase().trim();
    final sub = (subCategory ?? '').toLowerCase().trim();

    if (cat == 'privatephotos' || cat == 'private photos' || cat == 'private' || cat == 'özel') {
      return true;
    }

    const privateKeywords = [
      'private', 'özel', 'ozel', 'الصور الخاصة', 'private fotos', 'προσωπικ',
      'fotos privadas', 'foto privada', 'photos privées', 'photo privée',
      'निजी', 'foto pribadi', 'foto private', 'プライベート', '비공개',
      'privéfoto', 'prywatne', 'личные', 'privata foton', 'ส่วนตัว', 'riêng tư', '隐私'
    ];

    for (final kw in privateKeywords) {
      if (cat.contains(kw) || sub.contains(kw) || t.contains(kw)) {
        return true;
      }
    }
    return false;
  }

  /// Helper alias for fileSizeBytes
  int get fileSize => fileSizeBytes;

  /// Helper alias for localImagePath
  String get filePath => localImagePath;

  /// Creates a copy with optionally modified fields
  Document copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    String? subCategory,
    bool clearSubCategory = false,
    String? localImagePath,
    String? filePath,
    String? tripId,
    bool clearTripId = false,
    String? fileType,
    String? notes,
    int? fileSizeBytes,
    String? cloudDataBase64,
    bool clearCloudData = false,
    String? fileExtension,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Document(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      subCategory: clearSubCategory ? null : (subCategory ?? this.subCategory),
      localImagePath: localImagePath ?? filePath ?? this.localImagePath,
      tripId: clearTripId ? null : (tripId ?? this.tripId),
      fileType: fileType ?? this.fileType,
      notes: notes ?? this.notes,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      cloudDataBase64: clearCloudData ? null : (cloudDataBase64 ?? this.cloudDataBase64),
      fileExtension: fileExtension ?? this.fileExtension,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Serialization for Cloud Firestore / JSON APIs
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'user_id': userId,
      'title': title,
      'category': category,
      'subCategory': subCategory,
      'sub_category': subCategory,
      'localImagePath': localImagePath,
      'local_image_path': localImagePath,
      'tripId': tripId,
      'trip_id': tripId,
      'fileType': fileType ?? (isPdf ? 'pdf' : 'image'),
      'file_type': fileType ?? (isPdf ? 'pdf' : 'image'),
      'notes': notes,
      'fileSizeBytes': fileSizeBytes,
      'file_size_bytes': fileSizeBytes,
      'cloudDataBase64': cloudDataBase64,
      'cloud_data_base64': cloudDataBase64,
      'fileExtension': fileExtension,
      'file_extension': fileExtension,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
      'is_deleted': isDeleted ? 1 : 0,
      'isPrivate': isPrivate,
      'is_private': isPrivate ? 1 : 0,
    };
  }

  /// Deserialization from Cloud Firestore / JSON APIs
  factory Document.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final localPath = (json['localImagePath'] ?? json['local_image_path'] ?? json['filePath'] ?? json['file_path'] ?? '') as String;
    final ext = (json['fileExtension'] ?? json['file_extension']) as String?;
    final fType = (json['fileType'] as String?) ??
        (ext == 'pdf' || localPath.toLowerCase().endsWith('.pdf') ? 'pdf' : 'image');

    var cat = json['category'] as String? ?? 'Other';
    final isExplicitlyPrivate = json['isPrivate'] == true ||
        json['is_private'] == true ||
        json['is_private'] == 1;
    if (isExplicitlyPrivate && !cat.toLowerCase().contains('private') && !cat.toLowerCase().contains('özel')) {
      cat = 'PrivatePhotos';
    }

    return Document(
      id: (json['id'] ?? '') as String,
      userId: (json['user_id'] ?? json['userId'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      category: cat,
      subCategory: (json['subCategory'] ?? json['sub_category']) as String?,
      localImagePath: localPath,
      tripId: json['tripId'] as String?,
      fileType: fType,
      notes: json['notes'] as String?,
      fileSizeBytes: (json['file_size_bytes'] ?? json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      cloudDataBase64: (json['cloudDataBase64'] ?? json['cloud_data_base64']) as String?,
      fileExtension: ext,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? parseDate(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? parseDate(json['updatedAt'] ?? json['updated_at'])
          : DateTime.now(),
      isDeleted: json['isDeleted'] as bool? ?? json['is_deleted'] == true || json['is_deleted'] == 1,
    );
  }

  /// Serialization for local SQLite database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'sub_category': subCategory,
      'local_image_path': localImagePath,
      'trip_id': tripId,
      'file_type': fileType ?? (isPdf ? 'pdf' : 'image'),
      'notes': notes,
      'file_size_bytes': fileSizeBytes,
      'cloud_data_base64': cloudDataBase64,
      'file_extension': fileExtension,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
      'is_private': isPrivate ? 1 : 0,
    };
  }

  /// Deserialization from local SQLite database
  factory Document.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) {
        final parsed = DateTime.tryParse(val);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    final localPath = (map['local_image_path'] ?? map['file_path'] ?? '') as String;
    final ext = (map['file_extension'] ?? map['fileExtension']) as String?;
    final fType = (map['file_type'] ?? map['fileType'] as String?) ??
        (ext == 'pdf' || localPath.toLowerCase().endsWith('.pdf') ? 'pdf' : 'image');

    var cat = map['category'] as String? ?? 'Other';
    final isExplicitlyPrivate = map['is_private'] == 1 || map['isPrivate'] == true;
    if (isExplicitlyPrivate && !cat.toLowerCase().contains('private') && !cat.toLowerCase().contains('özel')) {
      cat = 'PrivatePhotos';
    }

    return Document(
      id: map['id'] as String,
      userId: (map['user_id'] ?? map['userId'] ?? '') as String,
      title: map['title'] as String,
      category: cat,
      subCategory: (map['sub_category'] ?? map['subCategory']) as String?,
      localImagePath: localPath,
      tripId: (map['trip_id'] ?? map['tripId']) as String?,
      fileType: fType,
      notes: map['notes'] as String?,
      fileSizeBytes: (map['file_size_bytes'] ?? map['fileSizeBytes'] as num?)?.toInt() ?? 0,
      cloudDataBase64: (map['cloud_data_base64'] ?? map['cloudDataBase64']) as String?,
      fileExtension: ext,
      createdAt: parseDate(map['created_at'] ?? map['createdAt']),
      updatedAt: parseDate(map['updated_at'] ?? map['updatedAt']),
      isDeleted: (map['is_deleted'] as int? ?? 0) == 1,
    );
  }
}

/// Type alias for Document to support VaultDocument naming interchangeably
typedef VaultDocument = Document;
