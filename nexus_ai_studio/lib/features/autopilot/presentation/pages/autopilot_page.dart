import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/nexus_card.dart';
import '../../bloc/autopilot_bloc.dart';

class AutopilotPage extends StatefulWidget {
  const AutopilotPage({super.key});
  @override State<AutopilotPage> createState() => _AutopilotPageState();
}

class _AutopilotPageState extends State<AutopilotPage> {
  List<String> _niches = ['ai'];
  List<String> _platforms = ['youtube', 'tiktok'];
  int _dailyLimit = 3;
  String _language = 'english';
  int _duration = 60;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AutopilotBloc, AutopilotState>(
      listener: (context, state) {
        if (state is AutopilotError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: NexusColors.error),
          );
        }
      },
      child: BlocBuilder<AutopilotBloc, AutopilotState>(
        builder: (context, state) {
          final isActive = state is AutopilotActiveState;
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Autopilot Mode', style: Theme.of(context).textTheme.headlineMedium),
                  const Text('Fully automated content factory', style: TextStyle(fontSize: 12, color: NexusColors.textMuted)),
                ]),
              )),

              // Main toggle card
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(child: _ToggleCard(isActive: isActive, state: state).animate().fadeIn().scale(begin: const Offset(0.95, 0.95))),
              ),

              // Pipeline steps
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                sliver: SliverToBoxAdapter(child: _PipelineCard(isActive: isActive)),
              ),

              // Config
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                sliver: SliverToBoxAdapter(child: _ConfigCard(
                  niches: _niches, platforms: _platforms,
                  dailyLimit: _dailyLimit, language: _language, duration: _duration,
                  onNichesChanged: (v) => setState(() => _niches = v),
                  onPlatformsChanged: (v) => setState(() => _platforms = v),
                  onDailyLimitChanged: (v) => setState(() => _dailyLimit = v),
                  onLanguageChanged: (v) => setState(() => _language = v),
                  onSave: () {
                    context.read<AutopilotBloc>().add(UpdateAutopilotConfigEvent(
                      niches: _niches, platforms: _platforms,
                      dailyLimit: _dailyLimit, duration: _duration, language: _language,
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Configuration saved')));
                  },
                )),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  final bool isActive;
  final AutopilotState state;
  const _ToggleCard({required this.isActive, required this.state});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive ? [const Color(0xFF064E3B), NexusColors.surface] : [NexusColors.surface, NexusColors.surfaceVariant],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isActive ? NexusColors.accent : NexusColors.border, width: isActive ? 1.5 : 1),
        boxShadow: isActive ? [BoxShadow(color: NexusColors.accent.withOpacity(0.2), blurRadius: 20)] : [],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: (isActive ? NexusColors.accent : NexusColors.textMuted).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(isActive ? Icons.smart_toy_rounded : Icons.bolt_rounded, color: isActive ? NexusColors.accent : NexusColors.textMuted, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isActive ? 'AUTOPILOT ACTIVE' : 'Autopilot Off',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isActive ? NexusColors.accent : NexusColors.textSecondary)),
            if (isActive && state is AutopilotActiveState)
              Row(children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: NexusColors.accent, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('${(state as AutopilotActiveState).videosToday} videos created today', style: const TextStyle(fontSize: 11, color: NexusColors.accent)),
              ])
            else
              const Text('Enable for fully automated content creation', style: TextStyle(fontSize: 12, color: NexusColors.textMuted)),
          ])),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: ElevatedButton.icon(
            onPressed: () => context.read<AutopilotBloc>().add(ToggleAutopilotEvent(!isActive)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive ? const Color(0xFF450A0A) : NexusColors.primary,
              foregroundColor: isActive ? NexusColors.error : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                side: isActive ? const BorderSide(color: NexusColors.error) : BorderSide.none),
            ),
            icon: Icon(isActive ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 18),
            label: Text(isActive ? 'Stop Autopilot' : 'Enable Autopilot', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          )),
          if (!isActive) ...[
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () {
                context.read<AutopilotBloc>().add(RunAutopilotNowEvent());
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🤖 Running one autopilot cycle…')));
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: NexusColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Run Once', style: TextStyle(color: NexusColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
            ),
          ],
        ]),
      ]),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  final bool isActive;
  const _PipelineCard({required this.isActive});

  static const _steps = [
    _Step('① Trend Scan', 'Google · Reddit · YouTube — every 2 hours', NexusColors.primary, Icons.trending_up_rounded),
    _Step('② Script', 'Claude AI writes retention-optimized viral script', NexusColors.primaryVar, Icons.edit_rounded),
    _Step('③ Voiceover', 'Edge TTS or ElevenLabs narration generation', NexusColors.pink, Icons.mic_rounded),
    _Step('④ Video', 'FFmpeg: stock clips + subtitles + music → 9:16', NexusColors.warning, Icons.videocam_rounded),
    _Step('⑤ Upload', 'Optimal-time posting to all configured platforms', NexusColors.accent, Icons.upload_rounded),
    _Step('⑥ Learn', 'Analytics → AI memory improves next video', NexusColors.cyan, Icons.psychology_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Automation Pipeline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 14),
        ..._steps.asMap().entries.map((e) {
          final s = e.value;
          final i = e.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                  width: 34, height: 34,
                  decoration: BoxDecoration(
                    color: s.color.withOpacity(isActive ? 0.2 : 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: s.color.withOpacity(isActive ? 0.6 : 0.2)),
                  ),
                  child: Icon(s.icon, color: s.color.withOpacity(isActive ? 1 : 0.4), size: 15),
                ),
                if (i < _steps.length - 1)
                  Container(width: 1, height: 12, color: s.color.withOpacity(isActive ? 0.3 : 0.1), margin: const EdgeInsets.symmetric(vertical: 2)),
              ]),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isActive ? NexusColors.textPrimary : NexusColors.textMuted)),
                Text(s.desc, style: const TextStyle(fontSize: 11, color: NexusColors.textMuted, height: 1.3)),
              ])),
              if (isActive)
                Icon(Icons.check_circle_rounded, color: s.color, size: 15).animate(delay: Duration(milliseconds: i * 150)).fadeIn(),
            ]),
          ).animate(delay: Duration(milliseconds: i * 60)).fadeIn();
        }),
      ]),
    );
  }
}

class _Step { final String title, desc; final Color color; final IconData icon; const _Step(this.title, this.desc, this.color, this.icon); }

class _ConfigCard extends StatelessWidget {
  final List<String> niches, platforms;
  final int dailyLimit; final String language; final int duration;
  final ValueChanged<List<String>> onNichesChanged, onPlatformsChanged;
  final ValueChanged<int> onDailyLimitChanged;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onSave;

  const _ConfigCard({required this.niches, required this.platforms, required this.dailyLimit, required this.language, required this.duration, required this.onNichesChanged, required this.onPlatformsChanged, required this.onDailyLimitChanged, required this.onLanguageChanged, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return NexusCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Configuration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),

        _cfgSection('Platforms', Wrap(spacing: 6, runSpacing: 6, children: AppConstants.platforms.map((p) {
          final active = platforms.contains(p);
          return GestureDetector(
            onTap: () { final next = [...platforms]; active ? next.remove(p) : next.add(p); if (next.isNotEmpty) onPlatformsChanged(next); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: active ? NexusColors.primary.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? NexusColors.primary : NexusColors.border),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(AppConstants.platformEmojis[p] ?? '📱', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text('${p[0].toUpperCase()}${p.substring(1)}', style: TextStyle(fontSize: 12, color: active ? NexusColors.primary : NexusColors.textMuted, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
              ]),
            ),
          );
        }).toList())),

        _cfgSection('Niches', Wrap(spacing: 6, runSpacing: 6, children: AppConstants.niches.take(6).map((n) {
          final active = niches.contains(n);
          return GestureDetector(
            onTap: () { final next = [...niches]; active ? next.remove(n) : next.add(n); if (next.isNotEmpty) onNichesChanged(next); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: active ? NexusColors.primaryVar.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? NexusColors.primaryVar : NexusColors.border),
              ),
              child: Text('${AppConstants.nicheEmojis[n] ?? ''} ${n[0].toUpperCase()}${n.substring(1)}',
                style: TextStyle(fontSize: 12, color: active ? NexusColors.primaryVar : NexusColors.textMuted, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
            ),
          );
        }).toList())),

        _cfgSection('Language', Wrap(spacing: 6, children: AppConstants.languages.map((l) {
          final active = l == language;
          return GestureDetector(
            onTap: () => onLanguageChanged(l),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active ? NexusColors.primary.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? NexusColors.primary : NexusColors.border),
              ),
              child: Text('${l[0].toUpperCase()}${l.substring(1)}', style: TextStyle(fontSize: 12, color: active ? NexusColors.primary : NexusColors.textMuted, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
            ),
          );
        }).toList())),

        _cfgSection('Daily Limit: $dailyLimit videos/day', Slider(
          value: dailyLimit.toDouble(), min: 1, max: 10, divisions: 9,
          activeColor: NexusColors.primary, inactiveColor: NexusColors.surfaceVariant,
          label: '$dailyLimit/day',
          onChanged: (v) => onDailyLimitChanged(v.toInt()),
        )),

        const SizedBox(height: 6),
        SizedBox(width: double.infinity, child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save Configuration'),
        )),
      ]),
    );
  }

  Widget _cfgSection(String label, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: NexusColors.textMuted, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        content,
      ]),
    );
  }
}
