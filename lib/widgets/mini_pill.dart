import 'package:flutter/material.dart';

class MiniPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final bool showBorder;

  const MiniPill({super.key, required this.icon, required this.text, this.color, this.showBorder = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? cs.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: showBorder ? Border.all(
          color: cs.outlineVariant
        ) : null
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: cs.onSurfaceVariant, fontFeatures: [FontFeature.tabularFigures()], fontFamily: 'Roboto'),
          ),
        ],
      ),
    );
  }
}
