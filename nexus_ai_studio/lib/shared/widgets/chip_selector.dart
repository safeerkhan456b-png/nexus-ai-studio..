import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ChipSelector<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  const ChipSelector({super.key, required this.options, required this.selected, required this.label, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: options.map((opt) {
        final active = opt == selected;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: active ? NexusColors.primary : NexusColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: active ? NexusColors.primary : NexusColors.border),
            ),
            child: Text(label(opt), style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? Colors.white : NexusColors.textMuted)),
          ),
        );
      }).toList(),
    );
  }
}
