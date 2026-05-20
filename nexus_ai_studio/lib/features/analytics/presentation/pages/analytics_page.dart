import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/nexus_card.dart';
import '../../bloc/analytics_bloc.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  static const _weeklyViews = [12400, 18900, 15600, 31200, 44800, 38900, 52100];
  static const _weekLabels  = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static const _insights = [
    _InsightItem('⏰', 'Best Posting Time', 'Videos posted 6–8 PM get 34% more views in your niche', NexusColors.primary),
    _InsightItem('🔥', 'Trending Format', 'Horror + AI hybrid content is surging right now', NexusColors.pink),
    _InsightItem('🎣', 'Hook Pattern', '"They never told you..." style hooks → 2.4× retention', NexusColors.warning),
    _InsightItem('⏱', 'Duration Sweet Spot', '60-second videos outperform 90s by 28% watch-through', NexusColors.accent),
    _InsightItem('📱', 'Top Platform', 'TikTok delivers 3.2× more reach than YouTube in your niche', NexusColors.cyan),
  ];

  static const _topVideos = [
    _VideoItem('🎬', 'AI Replaced My Entire Workflow', '52.1K', '78%', '4.2K', 'YouTube'),
    _VideoItem('🏛️', 'They Hid This For 1000 Years', '44.8K', '71%', '3.8K', 'TikTok'),
    _VideoItem('💰', 'The Crypto Signal Nobody Sees', '38.9K', '68%', '2.9K', 'Instagram'),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Analytics', style: Theme.of(context).textTheme.headlineMedium),
              const Text('Last 28 days · All platforms', style: TextStyle(fontSize: 12, color: NexusColors.textMuted)),
            ]),
            const Spacer(),
            BlocBuilder<AnalyticsBloc, AnalyticsState>(builder: (context, state) {
              return GestureDetector(
                onTap: () => context.read<AnalyticsBloc>().add(RunAnalyticsEvent()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: NexusColors.surfaceVariant, borderRadius: BorderRadius.circular(20), border: Border.all(color: NexusColors.border)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (state is AnalyticsLoading)
                      const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: NexusColors.primary))
                    else
                      const Icon(Icons.refresh_rounded, size: 12, color: NexusColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(state is AnalyticsLoading ? 'Fetching…' : 'Refresh', style: const TextStyle(fontSize: 12, color: NexusColors.textSecondary)),
                  ]),
                ),
              );
            }),
          ]),
        )),

        // Stat grid
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(child: GridView.count(
            crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), childAspectRatio: 1.65,
            children: const [
              _StatTile('Total Views', '213K', '↑ 47K', Icons.visibility_rounded, NexusColors.primary),
              _StatTile('New Subs', '+1.2K', '↑ 340', Icons.people_rounded, NexusColors.accent),
              _StatTile('Avg CTR', '8.4%', '↑ 1.2%', Icons.ads_click_rounded, NexusColors.warning),
              _StatTile('Avg Retention', '71%', '↑ 5%', Icons.timer_rounded, NexusColors.pink),
            ].map((t) => t).toList()
              ..asMap().entries.map((e) => e.value.animate(delay: Duration(milliseconds: e.key * 80)).fadeIn().scale(begin: const Offset(0.9, 0.9))).toList(),
          )),
        ),

        // Chart
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          sliver: SliverToBoxAdapter(child: _WeeklyChart(data: _weeklyViews, labels: _weekLabels)),
        ),

        // Top videos
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🏆 Top Performing', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: NexusColors.textPrimary)),
              const SizedBox(height: 10),
              ..._topVideos.asMap().entries.map((e) => _TopVideoCard(item: e.value)
                  .animate(delay: Duration(milliseconds: e.key * 80)).fadeIn()),
            ]),
          ),
        ),

        // AI Insights
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          sliver: SliverToBoxAdapter(
            child: NexusCard(
              borderColor: NexusColors.accent.withOpacity(0.2),
              gradientColors: [NexusColors.accent.withOpacity(0.07), NexusColors.surface],
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.psychology_rounded, color: NexusColors.accent, size: 16),
                  SizedBox(width: 6),
                  Text('AI Pattern Analysis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: NexusColors.accent)),
                ]),
                const SizedBox(height: 14),
                ..._insights.asMap().entries.map((e) => _InsightRow(item: e.value)
                    .animate(delay: Duration(milliseconds: e.key * 70)).fadeIn()),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value, delta;
  final IconData icon; final Color color;
  const _StatTile(this.label, this.value, this.delta, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(14),
      borderColor: color.withOpacity(0.2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: NexusColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        ]),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: NexusColors.textPrimary, letterSpacing: -0.5)),
        Text(delta, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<int> data; final List<String> labels;
  const _WeeklyChart({required this.data, required this.labels});

  @override
  Widget build(BuildContext context) {
    final max = data.reduce((a, b) => a > b ? a : b).toDouble();
    return NexusCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Weekly Views', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: NexusColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: const Text('↑ 28% vs last week', style: TextStyle(fontSize: 10, color: NexusColors.accent, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 88,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(data.length, (i) {
            final ratio = data[i] / max;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 700 + i * 80),
                    curve: Curves.easeOutCubic,
                    height: 70 * ratio,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [NexusColors.primary.withOpacity(0.9), NexusColors.primary.withOpacity(0.3)],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [BoxShadow(color: NexusColors.primary.withOpacity(0.3), blurRadius: 6)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i], style: const TextStyle(fontSize: 9, color: NexusColors.textMuted)),
                ]),
              ),
            );
          })),
        ),
      ]),
    );
  }
}

class _VideoItem {
  final String emoji, title, views, retention, likes, platform;
  const _VideoItem(this.emoji, this.title, this.views, this.retention, this.likes, this.platform);
}

class _TopVideoCard extends StatelessWidget {
  final _VideoItem item;
  const _TopVideoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Text(item.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(children: [
            Text('👁 ${item.views}', style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
            const SizedBox(width: 10),
            Text('⏱ ${item.retention}', style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
            const SizedBox(width: 10),
            Text('❤️ ${item.likes}', style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: NexusColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(item.platform, style: const TextStyle(fontSize: 10, color: NexusColors.primary, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

class _InsightItem {
  final String emoji, title, desc; final Color color;
  const _InsightItem(this.emoji, this.title, this.desc, this.color);
}

class _InsightRow extends StatelessWidget {
  final _InsightItem item;
  const _InsightRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 14))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: item.color)),
          const SizedBox(height: 2),
          Text(item.desc, style: const TextStyle(fontSize: 11, color: NexusColors.textMuted, height: 1.4)),
        ])),
      ]),
    );
  }
}
