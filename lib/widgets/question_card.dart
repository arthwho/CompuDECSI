import 'package:compudecsi/models/question.dart';
import 'package:compudecsi/services/question_service.dart';
import 'package:compudecsi/utils/app_theme.dart';
import 'package:compudecsi/utils/role_guard.dart';
import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String sessionId;
  final Question question;
  final QuestionService service;

  const QuestionCard({
    super.key,
    required this.sessionId,
    required this.question,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.customBorder, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12, left: 16, right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _StatusChip(status: question.status, pinned: question.pinned),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  question.authorName == null || question.authorName!.isEmpty
                      ? 'Anônimo'
                      : question.authorName!,
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // vote button shows current count and state
                    // We re-import locally to avoid circular deps
                    // ignore: prefer_const_constructors
                    _Vote(sessionId: sessionId, q: question, service: service),
                  ],
                ),
              ],
            ),
            RoleGuard(
              requiredRoles: {'admin', 'speaker'},
              builder: (_) => _ModeratorActions(
                sessionId: sessionId,
                q: question,
                service: service,
              ),
              fallback: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool pinned;
  const _StatusChip({required this.status, required this.pinned});

  @override
  Widget build(BuildContext context) {
    final text = pinned
        ? 'Fixada'
        : status == 'accepted'
        ? 'Aceita'
        : status == 'answered'
        ? 'Respondida'
        : status == 'rejected'
        ? 'Rejeitada'
        : 'Pendente';
    final color = pinned
        ? Colors.deepPurple
        : status == 'accepted'
        ? Colors.green
        : status == 'answered'
        ? Colors.blue
        : status == 'rejected'
        ? Colors.red
        : Colors.grey;
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}

class _Vote extends StatelessWidget {
  final String sessionId;
  final Question q;
  final QuestionService service;
  const _Vote({
    required this.sessionId,
    required this.q,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () =>
          service.toggleVote(sessionId: sessionId, questionId: q.id),
      icon: const Icon(Icons.thumb_up_outlined),
      label: Text(q.voteCount.toString()),
    );
  }
}

class _ModeratorActions extends StatelessWidget {
  final String sessionId;
  final Question q;
  final QuestionService service;
  const _ModeratorActions({
    required this.sessionId,
    required this.q,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          tooltip: 'Aceitar',
          onPressed: () => service.setStatus(
            sessionId: sessionId,
            questionId: q.id,
            status: 'accepted',
          ),
          icon: Icon(
            Icons.check_circle_outline,
            color: Theme.of(context).extension<CustomColors>()?.success,
          ),
        ),
        IconButton(
          tooltip: 'Responder',
          onPressed: () => service.setStatus(
            sessionId: sessionId,
            questionId: q.id,
            status: 'answered',
          ),
          icon: Icon(
            Icons.record_voice_over_outlined,
            color: context.customLightBlue,
          ),
        ),
        IconButton(
          tooltip: q.pinned ? 'Desfixar' : 'Fixar',
          onPressed: () => service.setPinned(
            sessionId: sessionId,
            questionId: q.id,
            pinned: !q.pinned,
          ),
          icon: Icon(
            q.pinned ? Icons.push_pin : Icons.push_pin_outlined,
            color: context.customGrey,
          ),
        ),
        IconButton(
          tooltip: 'Rejeitar',
          onPressed: () => service.setStatus(
            sessionId: sessionId,
            questionId: q.id,
            status: 'rejected',
          ),
          icon: Icon(
            Icons.cancel_outlined,
            color: Theme.of(context).extension<CustomColors>()?.error,
          ),
        ),
      ],
    );
  }
}
