import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String text;
  final String authorId;
  final String? authorName;
  final Timestamp? createdAt;
  final int voteCount;
  final String status; // pending | accepted | rejected | answered
  final bool pinned;
  final Timestamp? acceptedAt;
  final Timestamp? answeredAt;
  final int statusOrder; // for ordering in queries

  const Question({
    required this.id,
    required this.text,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    required this.voteCount,
    required this.status,
    required this.pinned,
    required this.acceptedAt,
    required this.answeredAt,
    required this.statusOrder,
  });

  static int mapStatusOrder(String status) {
    switch (status) {
      case 'pinned':
        return 0;
      case 'accepted':
        return 1;
      case 'pending':
        return 2;
      case 'answered':
        return 3;
      case 'rejected':
        return 4;
      default:
        return 9;
    }
  }

  factory Question.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final status = (d['status'] as String?) ?? 'pending';
    return Question(
      id: doc.id,
      text: (d['text'] as String?)?.trim() ?? '',
      authorId: d['authorId'] as String? ?? '',
      authorName: d['authorName'] as String?,
      createdAt: d['createdAt'] as Timestamp?,
      voteCount: (d['voteCount'] as int?) ?? 0,
      status: status,
      pinned: (d['pinned'] as bool?) ?? false,
      acceptedAt: d['acceptedAt'] as Timestamp?,
      answeredAt: d['answeredAt'] as Timestamp?,
      statusOrder: (d['statusOrder'] as int?) ?? mapStatusOrder(status),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': createdAt,
      'voteCount': voteCount,
      'status': status,
      'pinned': pinned,
      'acceptedAt': acceptedAt,
      'answeredAt': answeredAt,
      'statusOrder': statusOrder,
    };
  }
}
