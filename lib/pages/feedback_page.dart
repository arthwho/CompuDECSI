import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:compudecsi/services/feedback_service.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/widgets/rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  final String eventId;
  final String? eventTitle;
  final String? sessionId;

  const FeedbackPage({
    super.key,
    required this.eventId,
    this.eventTitle,
    this.sessionId,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _service = FeedbackService();
  final _commentCtrl = TextEditingController();
  int _rating = 5;
  bool _submitting = false;
  String? _existingId;

  @override
  void initState() {
    super.initState();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final entry = await _service.getUserFeedbackForEvent(uid, widget.eventId);
    if (entry != null) {
      setState(() {
        _existingId = entry.id;
        _rating = entry.rating;
        _commentCtrl.text = entry.comment ?? '';
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await _service.submit(
        eventId: widget.eventId,
        rating: _rating,
        comment: _commentCtrl.text.trim().isEmpty
            ? null
            : _commentCtrl.text.trim(),
        sessionId: widget.sessionId,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            _existingId == null
                ? 'Feedback enviado! Obrigado.'
                : 'Feedback atualizado!',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventTitle ?? 'Avaliar evento')),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.viewPortSide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como você avalia esta palestra/evento?',
              style: AppTextStyle.heading1,
            ),
            const SizedBox(height: 8),
            RatingBar(
              value: _rating,
              onChanged: (v) => setState(() => _rating = v),
            ),
            const SizedBox(height: 16),
            Text('Comentário (opcional)', style: AppTextStyle.heading2),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Conte como foi sua experiência...',
                filled: true,
                fillColor: const Color(0xffececf8),
                border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.md,
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: AppButtonStyle.btnPrimary,
                child: Text(
                  _existingId == null
                      ? 'Enviar feedback'
                      : 'Atualizar feedback',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
