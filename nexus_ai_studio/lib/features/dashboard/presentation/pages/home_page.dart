import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/nexus_card.dart';
import '../../../../shared/widgets/nexus_progress_bar.dart';
import '../../../../core/models/queue_item_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const _weeklyViews = [12400, 18900, 15600, 31200, 44800, 38900, 52100];
  static const _weekLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _Header()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          sliver: SliverToBoxAdapter(child: _StatsRow()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(child: _WeeklyChart(data: _weeklyViews, labels: _weekLabels)),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(child: _MiniQueue()),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverToBoxAdapter(child: _AiInsightsCard()),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [NexusColors.primary, NexusColors.primaryVar], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: NexusColors.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEXUS AI STUDIO', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              const Text('Command Center', style: TextStyle(fontSize: 11, color: NexusColors.textMuted)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: NexusColors.textSecondary, size: 22),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  static const _stats = [
    _StatData('Views', '213K', '↑ 47K', Icons.visibility_rounded, NexusColors.primary),
    _StatData('Subs', '+1.2K', '↑ 340', Icons.people_rounded, NexusColors.accent),
    _StatData('Revenue', '\$847', '↑ \$192', Icons.attach_money_rounded, NexusColors.warning),
    _StatData('CTR', '8.4%', '↑ 1.2%', Icons.ads_click_rounded, NexusColors.pink),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _StatCard(data: _stats[i]).animate(delay: Duration(milliseconds: i * 80)).fadeIn().slideY(begin: 0.3),
      ),
    );
  }
}

class _StatData {
  final String label, value, delta;
  final IconData icon; final Color color;
  const _StatData(this.label, this.value, this.delta, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(14),
      borderColor: data.color.withOpacity(0.2),
      child: SizedBox(
        width: 128,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(data.icon, size: 12, color: data.color),
              const SizedBox(width: 4),
              Text(data.label, style: TextStyle(fontSize: 10, color: NexusColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
            ]),
            const Spacer(),
            Text(data.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: NexusColors.textPrimary, letterSpacing: -0.5)),
            Text(data.delta, style: TextStyle(fontSize: 11, color: data.color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Weekly Views', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: NexusColors.accent.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: const Text('↑ 28%', style: TextStyle(fontSize: 10, color: NexusColors.accent, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(data.length, (i) {
                final ratio = data[i] / max;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 600 + i * 80), curve: Curves.easeOutCubic,
                          height: 62 * ratio,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [NexusColors.primary.withOpacity(0.9), NexusColors.primary.withOpacity(0.3)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [BoxShadow(color: NexusColors.primary.withOpacity(0.3), blurRadius: 6)],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(labels[i], style: const TextStyle(fontSize: 9, color: NexusColors.textMuted)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniQueue extends StatelessWidget {
  static final _items = [
    _QItem('🎬', 'AI Replaced My Entire Team', 'YouTube', UploadStatus.uploading, 0.73),
    _QItem('🧠', 'Ancient Trick Doubles Memory', 'TikTok', UploadStatus.processing, 0.45),
    _QItem('💰', 'Why Rich People Sleep at 9PM', 'Instagram', UploadStatus.queued, 0.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text('Upload Queue', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('See All →', style: TextStyle(fontSize: 12, color: NexusColors.primary))),
        ]),
        const SizedBox(height: 6),
        ..._items.asMap().entries.map((e) {
          final item = e.value;
          final color = item.status == UploadStatus.uploading ? NexusColors.primary : item.status == UploadStatus.processing ? NexusColors.warning : NexusColors.textMuted;
          return NexusCard(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Text(item.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('📱 ${item.platform}', style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
                if (item.progress > 0 && item.status != UploadStatus.queued) ...[
                  const SizedBox(height: 5),
                  NexusProgressBar(value: item.progress, color: color),
                ],
              ])),
            ]),
          ).animate(delay: Duration(milliseconds: e.key * 80)).fadeIn();
        }),
      ],
    );
  }
}
class _QItem { final String emoji, title, platform; final UploadStatus status; final double progress; const _QItem(this.emoji, this.title, this.platform, this.status, this.progress); }

class _AiInsightsCard extends StatelessWidget {
  static const _insights = [
    '🕕  Videos posted 6–8 PM get 34% more views in your niche',
    '🔥  Horror + AI hybrid content is trending — capitalize now',
    '🎣  Hooks starting with "They never told you..." have 2.4× retention',
    '⏱  60-second videos outperform 90s by 28% watch-through rate',
  ];

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      borderColor: NexusColors.accent.withOpacity(0.2),
      gradientColors: [NexusColors.accent.withOpacity(0.08), NexusColors.surface],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.psychology_rounded, color: NexusColors.accent, size: 16),
            SizedBox(width: 6),
            Text('AI Insights', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: NexusColors.accent)),
          ]),
          const SizedBox(height: 12),
          ..._insights.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Text(e.value, style: const TextStyle(fontSize: 12, color: NexusColors.textSecondary, height: 1.4)),
          ).animate(delay: Duration(milliseconds: e.key * 80)).fadeIn()),
        ],
      ),
    );
  }
}
