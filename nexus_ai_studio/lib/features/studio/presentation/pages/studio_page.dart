import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/models/script_model.dart';
import '../../../../shared/widgets/nexus_card.dart';
import '../../../../shared/widgets/chip_selector.dart';
import '../../bloc/studio_bloc.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({super.key});
  @override State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _topicCtrl = TextEditingController();
  String _niche = 'ai', _language = 'english', _tone = 'educational', _voice = 'english_male';
  int _duration = 60;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); _topicCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudioBloc, StudioState>(
      listener: (context, state) {
        if (state is ScriptReady) _tabCtrl.animateTo(1);
        if (state is VoiceoverReady) _tabCtrl.animateTo(2);
        if (state is VideoReady) _tabCtrl.animateTo(3);
        if (state is StudioError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: NexusColors.error));
        }
      },
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('AI Studio', style: Theme.of(context).textTheme.headlineMedium),
            const Text('Script → Voice → Video → Upload', style: TextStyle(fontSize: 12, color: NexusColors.textMuted)),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(color: NexusColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(gradient: const LinearGradient(colors: [NexusColors.primary, NexusColors.primaryVar]), borderRadius: BorderRadius.circular(10)),
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 10),
                labelColor: Colors.white,
                unselectedLabelColor: NexusColors.textMuted,
                dividerColor: Colors.transparent,
                tabs: const [Tab(text: '① Script'), Tab(text: '② Voice'), Tab(text: '③ Video'), Tab(text: '④ Upload')],
              ),
            ),
          ]),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _ScriptTab(topicCtrl: _topicCtrl, niche: _niche, language: _language, tone: _tone, duration: _duration,
                onNiche: (v) => setState(() => _niche = v), onLanguage: (v) => setState(() => _language = v),
                onTone: (v) => setState(() => _tone = v), onDuration: (v) => setState(() => _duration = v),
                onGenerate: () {
                  if (_topicCtrl.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a topic'))); return; }
                  context.read<StudioBloc>().add(GenerateScriptEvent(topic: _topicCtrl.text.trim(), niche: _niche, duration: _duration, language: _language, tone: _tone));
                }),
              _VoiceTab(selectedVoice: _voice, onVoiceChange: (v) => setState(() => _voice = v),
                onGenerate: () {
                  final st = context.read<StudioBloc>().state;
                  if (st is ScriptReady) context.read<StudioBloc>().add(GenerateVoiceoverEvent(scriptText: st.script.fullScript, voice: _voice));
                }),
              const _VideoTab(),
              const _UploadTab(),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Script Tab ───────────────────────────────────────────────
class _ScriptTab extends StatelessWidget {
  final TextEditingController topicCtrl;
  final String niche, language, tone;
  final int duration;
  final ValueChanged<String> onNiche, onLanguage, onTone;
  final ValueChanged<int> onDuration;
  final VoidCallback onGenerate;

  const _ScriptTab({required this.topicCtrl, required this.niche, required this.language, required this.tone, required this.duration, required this.onNiche, required this.onLanguage, required this.onTone, required this.onDuration, required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudioBloc, StudioState>(builder: (context, state) {
      if (state is StudioGenerating && state.stage == 'script') {
        return _GeneratingView(msg: 'Writing your viral script…', sub: 'Applying retention psychology + emotional pacing');
      }
      if (state is ScriptReady) return _ScriptResultView(script: state.script);
      if (state is VoiceoverReady) return _ScriptResultView(script: state.script);

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        physics: const BouncingScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Label('Video Topic'),
          TextField(controller: topicCtrl, maxLines: 3, style: const TextStyle(fontSize: 14, color: NexusColors.textPrimary), decoration: const InputDecoration(hintText: 'e.g. "How AI is replacing creative jobs in 2025"')),
          const SizedBox(height: 20),
          _Label('Duration'),
          ChipSelector<int>(options: const [15, 30, 60, 90], selected: duration, label: (v) => '${v}s', onSelected: onDuration),
          const SizedBox(height: 20),
          _Label('Language'),
          ChipSelector<String>(options: const ['english', 'urdu', 'hindi'], selected: language, label: (v) => '${v[0].toUpperCase()}${v.substring(1)}', onSelected: onLanguage),
          const SizedBox(height: 20),
          _Label('Tone'),
          ChipSelector<String>(options: AppConstants.tones, selected: tone, label: (v) => '${v[0].toUpperCase()}${v.substring(1)}', onSelected: onTone),
          const SizedBox(height: 28),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: onGenerate,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Generate Script', style: TextStyle(fontSize: 15)),
          )),
        ]),
      );
    });
  }
}

class _ScriptResultView extends StatelessWidget {
  final ScriptModel script;
  const _ScriptResultView({required this.script});

  static const _segColors = {
    'hook': NexusColors.primary, 'body': NexusColors.warning,
    'climax': NexusColors.pink, 'cta': NexusColors.accent,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        NexusCard(
          borderColor: NexusColors.accent.withOpacity(0.3),
          gradientColors: [NexusColors.primary.withOpacity(0.1), NexusColors.surface],
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('✅ Script Generated', style: TextStyle(fontSize: 11, color: NexusColors.accent, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(script.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: NexusColors.textPrimary)),
            const SizedBox(height: 4),
            Text('${script.wordCount} words · ${script.estimatedDuration}s · ${script.language}', style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
          ]),
        ).animate().fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 12),
        ...script.segments.asMap().entries.map((e) {
          final seg = e.value;
          final color = _segColors[seg.type] ?? NexusColors.textMuted;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: NexusColors.surface, borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: color, width: 3), right: BorderSide(color: NexusColors.border), top: BorderSide(color: NexusColors.border), bottom: BorderSide(color: NexusColors.border)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('${seg.type.toUpperCase()} · ${seg.durationSeconds}s', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(seg.emotion, style: TextStyle(fontSize: 9, color: color))),
              ]),
              const SizedBox(height: 8),
              Text(seg.text, style: const TextStyle(fontSize: 13, color: NexusColors.textSecondary, height: 1.5)),
            ]),
          ).animate(delay: Duration(milliseconds: e.key * 70)).fadeIn();
        }),
        const SizedBox(height: 6),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.mic_rounded, size: 18),
          label: const Text('Generate Voiceover →'),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        )),
      ]),
    );
  }
}

// ─── Voice Tab ────────────────────────────────────────────────
class _VoiceTab extends StatelessWidget {
  final String selectedVoice;
  final ValueChanged<String> onVoiceChange;
  final VoidCallback onGenerate;

  const _VoiceTab({required this.selectedVoice, required this.onVoiceChange, required this.onGenerate});

  static const _voices = [
    _V('english_male', 'Andrew', 'English · Male', '🇺🇸', NexusColors.primary),
    _V('english_female', 'Ava', 'English · Female', '🇺🇸', NexusColors.primaryVar),
    _V('urdu_male', 'Asad', 'Urdu · Male', '🇵🇰', NexusColors.accent),
    _V('urdu_female', 'Uzma', 'Urdu · Female', '🇵🇰', Color(0xFF34D399)),
    _V('hindi_male', 'Madhur', 'Hindi · Male', '🇮🇳', NexusColors.warning),
    _V('hindi_female', 'Swara', 'Hindi · Female', '🇮🇳', Color(0xFFFCD34D)),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudioBloc, StudioState>(builder: (context, state) {
      if (state is StudioGenerating && state.stage == 'voiceover') {
        return _GeneratingView(msg: 'Generating AI voiceover…', sub: 'Converting script to natural speech');
      }
      if (state is VoiceoverReady) {
        return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_rounded, color: NexusColors.accent, size: 56),
          const SizedBox(height: 16),
          const Text('Voiceover Ready!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(state.audioPath.split('/').last, style: const TextStyle(color: NexusColors.textMuted, fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () {
              context.read<StudioBloc>().add(CreateVideoEvent(script: state.script.fullScript, voiceoverPath: state.audioPath, niche: 'general', duration: state.script.estimatedDuration));
            },
            icon: const Icon(Icons.videocam_rounded, size: 18),
            label: const Text('Create Video →'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        ])));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const _Label('Select Voice'),
          const SizedBox(height: 10),
          ..._voices.asMap().entries.map((e) {
            final v = e.value;
            final active = selectedVoice == v.key;
            return GestureDetector(
              onTap: () => onVoiceChange(v.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: active ? v.color.withOpacity(0.08) : NexusColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: active ? v.color : NexusColors.border, width: active ? 1.5 : 1),
                ),
                child: Row(children: [
                  Text(v.flag, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(v.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: active ? v.color : NexusColors.textPrimary)),
                    Text(v.subtitle, style: const TextStyle(fontSize: 11, color: NexusColors.textMuted)),
                  ])),
                  if (active) Icon(Icons.check_circle_rounded, color: v.color, size: 20),
                ]),
              ),
            ).animate(delay: Duration(milliseconds: e.key * 50)).fadeIn();
          }),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: (state is ScriptReady) ? onGenerate : null,
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: const Text('Generate Voiceover'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
          if (state is! ScriptReady && state is! VoiceoverReady)
            const Padding(padding: EdgeInsets.only(top: 12), child: Center(child: Text('⚠️  Generate a script first', style: TextStyle(fontSize: 12, color: NexusColors.textMuted)))),
        ]),
      );
    });
  }
}
class _V { final String key, name, subtitle, flag; final Color color; const _V(this.key, this.name, this.subtitle, this.flag, this.color); }

// ─── Video Tab ────────────────────────────────────────────────
class _VideoTab extends StatelessWidget {
  const _VideoTab();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudioBloc, StudioState>(builder: (context, state) {
      if (state is StudioGenerating && state.stage == 'video') {
        return _GeneratingView(msg: 'Assembling your video…', sub: 'FFmpeg: stock clips → voiceover → subtitles → music');
      }
      if (state is VideoAssembling) {
        return _GeneratingView(msg: 'Assembling your video…', sub: 'FFmpeg pipeline running — ${(state.progress * 100).toInt()}% complete', progress: state.progress);
      }
      if (state is VideoReady) {
        return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.movie_rounded, color: NexusColors.accent, size: 56),
          const SizedBox(height: 16),
          const Text('Video Ready!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(state.jobId, style: const TextStyle(color: NexusColors.textMuted, fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_rounded, size: 18),
            label: const Text('Upload to Platforms →'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        ])));
      }
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.videocam_outlined, color: NexusColors.textMuted, size: 48),
        SizedBox(height: 12),
        Text('Complete script & voiceover first', style: TextStyle(color: NexusColors.textMuted, fontSize: 13)),
      ]));
    });
  }
}

// ─── Upload Tab ───────────────────────────────────────────────
class _UploadTab extends StatelessWidget {
  const _UploadTab();
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudioBloc, StudioState>(builder: (context, state) {
      if (state is VideoReady) {
        return Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Select Platforms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: NexusColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 14),
          ...AppConstants.platforms.map((p) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: NexusColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: NexusColors.border)),
            child: Row(children: [
              Text(AppConstants.platformEmojis[p] ?? '📱', style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Text('${p[0].toUpperCase()}${p.substring(1)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Switch(value: p == 'youtube' || p == 'tiktok', onChanged: (_) {}, activeColor: NexusColors.primary),
            ]),
          )),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📤 Upload queued!'))),
            icon: const Icon(Icons.upload_rounded, size: 18),
            label: const Text('Upload Now', style: TextStyle(fontSize: 15)),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        ]));
      }
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.upload_outlined, color: NexusColors.textMuted, size: 48),
        SizedBox(height: 12),
        Text('Complete video creation first', style: TextStyle(color: NexusColors.textMuted, fontSize: 13)),
      ]));
    });
  }
}

// ─── Shared ───────────────────────────────────────────────────
class _GeneratingView extends StatelessWidget {
  final String msg, sub; final double? progress;
  const _GeneratingView({required this.msg, required this.sub, this.progress});
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
      if (progress != null)
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 70, height: 70, child: CircularProgressIndicator(value: progress, strokeWidth: 4, backgroundColor: NexusColors.surfaceVariant, valueColor: const AlwaysStoppedAnimation(NexusColors.primary))),
          Text('${((progress ?? 0) * 100).toInt()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ])
      else const SizedBox(width: 50, height: 50, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation(NexusColors.primary))),
      const SizedBox(height: 24),
      Text(msg, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
      const SizedBox(height: 8),
      Text(sub, style: const TextStyle(fontSize: 12, color: NexusColors.textMuted), textAlign: TextAlign.center),
    ])));
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: NexusColors.textMuted, letterSpacing: 0.8)),
  );
}
