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
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final idx = i + 1;
        final filled = idx <= value;
        return IconButton(
          onPressed: () => onChanged(idx),
          iconSize: size,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(),
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? AppColors.purple : AppColors.border,
          ),
        );
      }),
    );
  }
}
