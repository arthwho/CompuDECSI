import 'package:compudecsi/services/feedback_service.dart';
import 'package:compudecsi/utils/variables.dart';
import 'package:compudecsi/utils/app_theme.dart' as theme;
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

  String _getRatingEmoji(int rating) {
    switch (rating) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
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
      appBar: AppBar(
        title: Text('Avaliar evento'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: context.customBorder, height: 1.0),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.viewPortSide),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.eventTitle?.startsWith('Avaliar — ') == true
                  ? widget.eventTitle!.substring(10)
                  : (widget.eventTitle ?? 'Avaliar evento'),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.lg),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 0.8,
                        end: 1.0,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _getRatingEmoji(_rating),
                  key: ValueKey(_rating),
                  style: TextStyle(fontSize: 48),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Quantas estrelas você daria para este evento?',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: RatingBar(
                value: _rating,
                onChanged: (v) => setState(() => _rating = v),
              ),
            ),
            SizedBox(height: AppSpacing.lg * 2),
            Text('Faça um comentário! (opcional)'),
            const SizedBox(height: 8),
            TextField(
              controller: _commentCtrl,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline,
              enableSuggestions: true,
              autocorrect: true,
              decoration: InputDecoration(
                hintText: 'Conte como foi sua experiência...',
                border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.md,
                  borderSide: BorderSide(color: context.customBorder),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.customBorder, width: 1),
          ),
        ),
        child: BottomAppBar(
          color: Theme.of(context).cardColor,
          elevation: 8,
          height: 80,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _existingId == null ? 'Enviar feedback' : 'Atualizar feedback',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
