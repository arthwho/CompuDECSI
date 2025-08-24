import 'package:compudecsi/services/question_service.dart';
import 'package:flutter/material.dart';

class QuestionInput extends StatefulWidget {
  final String sessionId;
  final QuestionService service;

  const QuestionInput({
    super.key,
    required this.sessionId,
    required this.service,
  });

  @override
  State<QuestionInput> createState() => _QuestionInputState();
}

class _QuestionInputState extends State<QuestionInput> {
  final _controller = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.length < 5) return;
    setState(() => _submitting = true);
    try {
      await widget.service.submitQuestion(
        sessionId: widget.sessionId,
        text: text,
      );
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao enviar pergunta: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.send,
            keyboardType: TextInputType.multiline,
            enableSuggestions: true,
            autocorrect: true,
            decoration: const InputDecoration(
              hintText: 'Faça sua pergunta...',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
        ),
      ],
    );
  }
}
