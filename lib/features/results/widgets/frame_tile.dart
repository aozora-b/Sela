import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/models.dart';
import '../../../theme/sela_colors.dart';

/// Ubin tunggal frame pada kisi 3 kolom Layar 06 Hasil Ekstraksi.
class FrameTile extends StatelessWidget {
  const FrameTile({
    super.key,
    required this.frame,
    required this.isSelected,
    required this.onTap,
  });

  final FrameResult frame;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final file = File(frame.path);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.accent : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            file.existsSync()
                ? Image.file(
                    file,
                    fit: BoxFit.cover,
                    cacheWidth: 320,
                    gaplessPlayback: true,
                    errorBuilder: (_, _, _) => _buildPlaceholder(colors),
                  )
                : _buildPlaceholder(colors),
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? colors.accent : Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colors.accent : colors.border,
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(SelaColorsData colors) {
    return Container(
      color: colors.surfaceHighlight,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: colors.textSecondary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
