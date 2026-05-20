import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/queue_item_model.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/nexus_progress_bar.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/nexus_card.dart';
import '../../bloc/queue_bloc.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Upload Queue', style: Theme.of(context).textTheme.headlineMedium),
            BlocBuilder<QueueBloc, QueueState>(builder: (_, state) {
              final count = state is QueueLoaded ? state.items.where((i) => i.status != UploadStatus.published).length : 0;
              final done = state is QueueLoaded ? state.items.where((i) => i.status == UploadStatus.published).length : 0;
              return Text('$count active · $done published', style: const TextStyle(fontSize: 12, color: NexusColors.textMuted));
            }),
          ]),
          const Spacer(),
          IconButton(
            onPressed: () => context.read<QueueBloc>().add(RefreshQueueEvent()),
            icon: const Icon(Icons.refresh_rounded, color: NexusColors.textSecondary),
          ),
        ]),
      ),
      Expanded(
        child: BlocBuilder<QueueBloc, QueueState>(builder: (context, state) {
          if (state is QueueLoading) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: 5,
              itemBuilder: (_, __) => const LoadingShimmerCard(height: 90),
            );
          }
          if (state is QueueError) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.error_outline, color: NexusColors.error, size: 40),
              const SizedBox(height: 12),
              Text(state.message, style: const TextStyle(color: NexusColors.textMuted, fontSize: 13), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<QueueBloc>().add(RefreshQueueEvent()),
                child: const Text('Retry'),
              ),
            ]));
          }
          if (state is QueueLoaded) {
            if (state.items.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('📭', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                const Text('Queue is empty', style: TextStyle(color: NexusColors.textMuted, fontSize: 14)),
                const SizedBox(height: 8),
                const Text('Create a video in Studio to get started', style: TextStyle(color: NexusColors.textMuted, fontSize: 12)),
              ]));
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<QueueBloc>().add(RefreshQueueEvent()),
              color: NexusColors.primary,
              backgroundColor: NexusColors.surface,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.items.length,
                itemBuilder: (_, i) => _QueueCard(item: state.items[i])
                    .animate(delay: Duration(milliseconds: i * 60))
                    .fadeIn()
                    .slideX(begin: 0.15),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    ]);
  }
}

class _QueueCard extends StatelessWidget {
  final QueueItemModel item;
  const _QueueCard({required this.item});

  Color get _statusColor {
    switch (item.status) {
      case UploadStatus.uploading:  return NexusColors.primary;
      case UploadStatus.processing: return NexusColors.warning;
      case UploadStatus.published:  return NexusColors.accent;
      case UploadStatus.failed:     return NexusColors.error;
      case UploadStatus.queued:     return NexusColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(item.emoji, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              item.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NexusColors.textPrimary),
            ),
            const SizedBox(height: 3),
            Row(children: [
              const Icon(Icons.smartphone_rounded, size: 10, color: NexusColors.textMuted),
              const SizedBox(width: 3),
              Text(item.platform, style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
              const SizedBox(width: 10),
              const Icon(Icons.access_time_rounded, size: 10, color: NexusColors.textMuted),
              const SizedBox(width: 3),
              Text(item.createdAt, style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
            ]),
          ])),
          StatusBadge(status: item.status),
        ]),
        if (item.progress > 0 && item.status != UploadStatus.published && item.status != UploadStatus.failed) ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: NexusProgressBar(value: item.progress, color: _statusColor, height: 3)),
            const SizedBox(width: 8),
            Text(
              '${(item.progress * 100).toInt()}%',
              style: TextStyle(fontSize: 10, color: _statusColor, fontWeight: FontWeight.w700),
            ),
          ]),
        ],
        if (item.status == UploadStatus.failed && item.errorMessage != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: NexusColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.warning_amber_rounded, size: 12, color: NexusColors.error),
              const SizedBox(width: 6),
              Expanded(child: Text(item.errorMessage!, style: const TextStyle(fontSize: 11, color: NexusColors.error), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
          ),
        ],
        if (item.status == UploadStatus.published && item.platformVideoId != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: NexusColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, size: 12, color: NexusColors.accent),
              const SizedBox(width: 6),
              Text('Video ID: ${item.platformVideoId}', style: const TextStyle(fontSize: 11, color: NexusColors.accent)),
            ]),
          ),
        ],
      ]),
    ).animate().none();
  }
}
