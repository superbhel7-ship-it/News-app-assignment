import 'package:flutter/material.dart';
import '../../core/theme/theme_colors.dart';

/// Reusable topic chip widget (e.g., #iPhone, #Stocks).
/// Used in home screen Topics section and search screen.
class TopicChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const TopicChip(this.label, {super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.divider, width: 0.5),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
