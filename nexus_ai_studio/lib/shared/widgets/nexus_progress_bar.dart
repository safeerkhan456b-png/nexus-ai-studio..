import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NexusProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;

  const NexusProgressBar({super.key, required this.value, this.color, this.height = 3});

  @override
  Widget build(BuildContext context) {
    final c = color ?? NexusColors.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: NexusColors.surfaceVariant,
        valueColor: AlwaysStoppedAnimation(c),
        minHeight: height,
      ),
    );
  }
}
