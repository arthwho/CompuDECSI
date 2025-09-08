import 'package:flutter/material.dart';

class ThemeToggle extends StatelessWidget {
  final VoidCallback onToggle;
  final bool isDarkMode;

  const ThemeToggle({
    super.key,
    required this.onToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      tooltip: isDarkMode ? 'Mudar para modo claro' : 'Mudar para modo escuro',
    );
  }
}
