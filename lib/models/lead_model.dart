/// Lead model stored in Hive.
///
/// Each lead belongs to the logged-in user ([userId]). Leads are filtered by
/// userId on read so data stays scoped per user.
library;

class LeadModel {
  const LeadModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    this.email = '',
    this.company = '',
    required this.source,
    this.status = 'New',
    this.photoUrl,
    this.isFromApi = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String company;
  final String source;
  final String status;
  final String? photoUrl;
  final bool isFromApi;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Initials shown in the avatar when there is no photo.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'email': email,
      'company': company,
      'source': source,
      'status': status,
      'photoUrl': photoUrl,
      'isFromApi': isFromApi ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LeadModel.fromMap(Map<String, dynamic> map) {
    return LeadModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String? ?? '',
      company: map['company'] as String? ?? '',
      source: map['source'] as String,
      status: map['status'] as String,
      photoUrl: map['photoUrl'] as String?,
      isFromApi: (map['isFromApi'] as int?) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  LeadModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? email,
    String? company,
    String? source,
    String? status,
    String? photoUrl,
    bool? isFromApi,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeadModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      company: company ?? this.company,
      source: source ?? this.source,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      isFromApi: isFromApi ?? this.isFromApi,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'LeadModel(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LeadModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
