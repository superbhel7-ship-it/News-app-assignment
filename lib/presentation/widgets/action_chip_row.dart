import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_styles.dart';

/// A single action chip used in article detail (Highlight, Respond, Share).
class ActionChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const ActionChip({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: AppStyles.actionChipDecoration,
        child: Text(
          label,
          style: AppStyles.actionChipLabel,
        ),
      ),
    );
  }
}

/// Row of action chips (Highlight, Respond, Share, ...) used in article detail.
class ActionChipRow extends StatelessWidget {
  final List<String> labels;
  final bool showMoreButton;

  const ActionChipRow({
    super.key,
    this.labels = const ['Highlight', 'Respond', 'Share'],
    this.showMoreButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...labels.map((label) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(label: label),
            )),
        if (showMoreButton)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: AppStyles.actionChipDecoration,
            child: const Icon(Icons.more_horiz,
                size: 16, color: AppTheme.textSecondary),
          ),
      ],
    );
  }
}
