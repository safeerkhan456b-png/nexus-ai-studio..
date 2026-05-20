import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class NexusCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final double borderRadius;

  const NexusCard({
    super.key, required this.child,
    this.padding, this.borderColor, this.gradientColors, this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradientColors != null
            ? LinearGradient(colors: gradientColors!, begin: Alignment.topLeft, end: Alignment.bottomRight)
            : LinearGradient(colors: [NexusColors.surface, NexusColors.surfaceVariant], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor ?? NexusColors.border),
      ),
      child: child,
    );
  }
}
