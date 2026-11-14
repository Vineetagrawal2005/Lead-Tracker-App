/// Note model stored in Hive.
///
/// Notes belong to a lead ([leadId]) and are sorted newest first on read.
library;

class NoteModel {
  const NoteModel({
    required this.id,
    required this.leadId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String leadId;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'leadId': leadId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      leadId: map['leadId'] as String,
      text: map['text'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  NoteModel copyWith({
    String? id,
    String? leadId,
    String? text,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'NoteModel(id: $id, leadId: $leadId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NoteModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
