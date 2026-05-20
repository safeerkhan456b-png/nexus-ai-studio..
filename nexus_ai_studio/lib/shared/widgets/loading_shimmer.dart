import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';

class LoadingShimmerCard extends StatelessWidget {
  final double height;
  const LoadingShimmerCard({super.key, this.height = 130});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: NexusColors.surface,
      highlightColor: NexusColors.surfaceVariant,
      child: Container(
        height: height,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: NexusColors.surface, borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
