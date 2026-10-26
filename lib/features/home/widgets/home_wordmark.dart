import 'package:flutter/material.dart';

import '../../../theme/sela_colors.dart';

/// Wordmark `Sela.` dengan titik terracotta khas desain editorial Sela.
class HomeWordmark extends StatelessWidget {
  const HomeWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: 'Sela',
            style: TextStyle(color: colors.textPrimary),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(color: colors.accent),
          ),
        ],
      ),
    );
  }
}
