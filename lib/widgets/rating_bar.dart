import 'package:flutter/material.dart';
import 'package:compudecsi/utils/variables.dart';

class RatingBar extends StatelessWidget {
  final int value; // 1..5
  final void Function(int) onChanged;
  final double size;

  const RatingBar({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final filled = idx <= value;
        return AnimatedScale(
          scale: filled ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: IconButton(
              onPressed: () => onChanged(idx),
              iconSize: size,
              padding: const EdgeInsets.symmetric(horizontal: 2),
              constraints: const BoxConstraints(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  filled ? Icons.star : Icons.star_border,
                  key: ValueKey(filled),
                  color: filled ? Colors.amber : Colors.grey[400],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
