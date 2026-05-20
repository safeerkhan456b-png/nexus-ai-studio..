import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/trend_model.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/nexus_card.dart';
import '../../bloc/trends_bloc.dart';
import '../../../studio/bloc/studio_bloc.dart';

class TrendsPage extends StatefulWidget {
  const TrendsPage({super.key});
  @override State<TrendsPage> createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  String _niche = 'ai';

  @override
  void initState() {
    super.initState();
    context.read<TrendsBloc>().add(DiscoverTrendsEvent(niche: _niche));
  }

  void _scan() => context.read<TrendsBloc>().add(DiscoverTrendsEvent(niche: _niche));

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeader(context),
      _buildNicheFilter(),
      Expanded(child: BlocBuilder<TrendsBloc, TrendsState>(builder: (context, state) {
        if (state is TrendsLoading) return ListView.builder(padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), itemCount: 5, itemBuilder: (_, __) => const LoadingShimmerCard());
        if (state is TrendsError) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: NexusColors.error, size: 40),
          const SizedBox(height: 12),
          Text(state.message, style: const TextStyle(color: NexusColors.textMuted, fontSize: 13), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _scan, child: const Text('Retry')),
        ]));
        if (state is TrendsLoaded) {
          if (state.trends.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🔍', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text('No trends yet', style: TextStyle(color: NexusColors.textMuted)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _scan, child: const Text('Discover Trends')),
          ]));
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            physics: const BouncingScrollPhysics(),
            itemCount: state.trends.length,
            itemBuilder: (_, i) => _TrendCard(
              trend: state.trends[i],
              isSelected: state.selected?.title == state.trends[i].title,
              onTap: () => _onTrendTap(context, state.trends[i]),
            ).animate(delay: Duration(milliseconds: i * 60)).fadeIn().slideY(begin: 0.3),
          );
        }
        return const SizedBox.shrink();
      })),
    ]);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Trend Explorer', style: Theme.of(context).textTheme.headlineMedium),
          const Text('AI-scored · Reddit · YouTube · Google', style: TextStyle(fontSize: 12, color: NexusColors.textMuted)),
        ]),
        const Spacer(),
        BlocBuilder<TrendsBloc, TrendsState>(builder: (context, state) {
          final loading = state is TrendsLoading;
          return GestureDetector(
            onTap: loading ? null : _scan,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: loading ? null : const LinearGradient(colors: [NexusColors.warning, Color(0xFFD97706)]),
                color: loading ? NexusColors.surfaceVariant : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (loading) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: NexusColors.textMuted))
                else const Icon(Icons.local_fire_department_rounded, size: 14, color: Colors.black),
                const SizedBox(width: 6),
                Text(loading ? 'Scanning…' : 'Scan Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: loading ? NexusColors.textMuted : Colors.black)),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildNicheFilter() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: AppConstants.niches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final n = AppConstants.niches[i];
          final active = n == _niche;
          return GestureDetector(
            onTap: () {
              setState(() => _niche = n);
              context.read<TrendsBloc>().add(DiscoverTrendsEvent(niche: n));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: active ? NexusColors.primary : NexusColors.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? NexusColors.primary : NexusColors.border),
              ),
              child: Center(child: Text(
                '${AppConstants.nicheEmojis[n] ?? ''} ${n[0].toUpperCase()}${n.substring(1)}',
                style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400, color: active ? Colors.white : NexusColors.textMuted),
              )),
            ),
          );
        },
      ),
    );
  }

  void _onTrendTap(BuildContext context, TrendModel trend) {
    context.read<TrendsBloc>().add(SelectTrendEvent(trend));
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(value: context.read<StudioBloc>(), child: _TrendActionSheet(trend: trend)),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final TrendModel trend; final bool isSelected; final VoidCallback onTap;
  const _TrendCard({required this.trend, required this.isSelected, required this.onTap});

  static const _predColors = {
    'viral': NexusColors.accent, 'high': Color(0xFF34D399),
    'medium': NexusColors.warning, 'low': NexusColors.textMuted,
  };

  @override
  Widget build(BuildContext context) {
    final score = trend.viralScore.toInt();
    final predColor = _predColors[trend.engagementPrediction] ?? NexusColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected ? [const Color(0xFF1E1B4B), NexusColors.surfaceVariant] : [NexusColors.surface, NexusColors.surfaceVariant],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? NexusColors.primary : NexusColors.border, width: isSelected ? 1.5 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            SizedBox(width: 38, height: 38, child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(value: score / 100, strokeWidth: 3, backgroundColor: NexusColors.surfaceVariant, valueColor: AlwaysStoppedAnimation(score >= 90 ? NexusColors.accent : score >= 70 ? NexusColors.warning : NexusColors.primary)),
              Text('$score', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: NexusColors.textPrimary)),
            ])),
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: NexusColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text('#${trend.category}', style: const TextStyle(fontSize: 10, color: NexusColors.primary, fontWeight: FontWeight.w600))),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: predColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: predColor.withOpacity(0.3))), child: Text(trend.engagementPrediction.toUpperCase(), style: TextStyle(fontSize: 9, color: predColor, fontWeight: FontWeight.w700, letterSpacing: 0.5))),
          ]),
          const SizedBox(height: 8),
          Text(trend.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: NexusColors.textPrimary, height: 1.3)),
          const SizedBox(height: 5),
          Text(trend.scriptAngle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: NexusColors.textMuted, height: 1.4)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Wrap(spacing: 4, children: trend.hashtags.take(3).map((h) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: NexusColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(h, style: const TextStyle(fontSize: 10, color: NexusColors.primary)))).toList())),
            GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [NexusColors.primary, NexusColors.primaryVar]), borderRadius: BorderRadius.circular(20)), child: const Text('Create →', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)))),
          ]),
        ]),
      ),
    );
  }
}

class _TrendActionSheet extends StatelessWidget {
  final TrendModel trend;
  const _TrendActionSheet({required this.trend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(color: NexusColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), border: Border(top: BorderSide(color: NexusColors.border))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: NexusColors.border, borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text(trend.title, style: Theme.of(context).textTheme.titleLarge, maxLines: 2),
        const SizedBox(height: 18),
        _ActionBtn(Icons.auto_awesome_rounded, 'Generate Script', 'Claude AI writes a viral retention-optimized script', NexusColors.primary, () {
          Navigator.pop(context);
          context.read<StudioBloc>().add(GenerateScriptEvent(topic: trend.title, niche: trend.category, scriptAngle: trend.scriptAngle));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✨ Generating script — go to Studio tab!')));
        }),
        const SizedBox(height: 10),
        _ActionBtn(Icons.bolt_rounded, 'Autopilot This Topic', 'Add to full automation queue', NexusColors.accent, () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🤖 Added to autopilot queue!')));
        }),
        const SizedBox(height: 10),
        _ActionBtn(Icons.bookmark_outline_rounded, 'Save for Later', 'Bookmark this trend', NexusColors.warning, () => Navigator.pop(context)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon; final String label, subtitle; final Color color; final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.subtitle, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.25))),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: NexusColors.textPrimary)),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
          ])),
          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: color),
        ]),
      ),
    );
  }
}
