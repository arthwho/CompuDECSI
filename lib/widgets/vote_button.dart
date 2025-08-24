import 'package:compudecsi/services/question_service.dart';
import 'package:flutter/material.dart';

class VoteButton extends StatelessWidget {
  final String sessionId;
  final String questionId;
  final int voteCount;
  final QuestionService service;

  const VoteButton({
    super.key,
    required this.sessionId,
    required this.questionId,
    required this.voteCount,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: service.watchVoted(sessionId: sessionId, questionId: questionId),
      builder: (context, snap) {
        final voted = snap.data ?? false;
        return TextButton.icon(
          onPressed: () =>
              service.toggleVote(sessionId: sessionId, questionId: questionId),
          icon: Icon(
            voted ? Icons.thumb_up : Icons.thumb_up_outlined,
            color: voted ? Colors.blue : null,
          ),
          label: Text(voteCount.toString()),
        );
      },
    );
  }
}
