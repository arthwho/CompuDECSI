import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackEntry {
  final String id;
  final String eventId;
  final String? sessionId;
  final String userId;
  final int rating; // 1..5
  final String? comment;
  final Timestamp createdAt;

  FeedbackEntry({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.rating,
    required this.createdAt,
    this.sessionId,
    this.comment,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'sessionId': sessionId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt,
    };
  }

  factory FeedbackEntry.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FeedbackEntry(
      id: doc.id,
      eventId: data['eventId'] as String,
      sessionId: data['sessionId'] as String?,
      userId: data['userId'] as String,
      rating: (data['rating'] as num).toInt(),
      comment: data['comment'] as String?,
      createdAt: (data['createdAt'] as Timestamp?) ?? Timestamp.now(),
    );
  }
}
