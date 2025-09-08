import 'package:compudecsi/models/question.dart';
import 'package:compudecsi/services/question_service.dart';
import 'package:compudecsi/utils/app_theme.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/widgets/question_card.dart';
import 'package:compudecsi/widgets/question_input.dart';
import 'package:flutter/material.dart';

class QAPage extends StatelessWidget {
  final String sessionId;
  final String? sessionTitle;
  final QuestionService service;

  QAPage({
    super.key,
    required this.sessionId,
    this.sessionTitle,
    QuestionService? service,
  }) : service = service ?? QuestionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(sessionTitle ?? 'Q&A'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: context.customBorder, height: 1.0),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.viewPortSide),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Question>>(
                stream: service.watchQuestions(sessionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = snapshot.data ?? const <Question>[];
                  if (items.isEmpty) {
                    return const Center(
                      child: Text('Seja o primeiro a perguntar!'),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final q = items[index];
                      return QuestionCard(
                        sessionId: sessionId,
                        question: q,
                        service: service,
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            QuestionInput(sessionId: sessionId, service: service),
          ],
        ),
      ),
    );
  }
}
