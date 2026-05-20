import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/queue_item_model.dart';

class StatusBadge extends StatelessWidget {
  final UploadStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final cfg = _configs[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cfg.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cfg.color.withOpacity(0.4)),
      ),
      child: Text(cfg.label,
        style: TextStyle(fontFamily: 'Roboto', fontSize: 10, fontWeight: FontWeight.w700, color: cfg.color)),
    );
  }

  static final _configs = {
    UploadStatus.published: _Cfg('Published', NexusColors.accent),
    UploadStatus.uploading: _Cfg('Uploading', NexusColors.primary),
    UploadStatus.processing: _Cfg('Processing', NexusColors.warning),
    UploadStatus.queued: _Cfg('Queued', NexusColors.textMuted),
    UploadStatus.failed: _Cfg('Failed', NexusColors.error),
  };
}
class _Cfg { final String label; final Color color; const _Cfg(this.label, this.color); }
