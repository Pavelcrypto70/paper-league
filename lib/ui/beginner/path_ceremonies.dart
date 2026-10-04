import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/config/app_links.dart';
import 'package:paper_league/domain/models.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:paper_league/ui/screens/auth_gate_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const _reminderHours = [8, 13, 19, 22];

String _hh(int h) => '${h.toString().padLeft(2, '0')}:00';

/// Soft save-progress screen. The auth screen has no chrome of its own, so we add a close button.
Future<void> openSoftAuth(BuildContext context) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (ctx) => Stack(
        children: [
          AuthGateScreen(
            onReady: () {
              if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
            },
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  onPressed: () => Navigator.of(ctx).maybePop(),
                  icon: const Icon(Icons.close_rounded, color: PlColors.muted),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Future<int?> showReminderSheet(BuildContext context) {
  final desk = context.read<DeskController>();
  var hour = desk.reminderHour ?? 19;
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: PlColors.bg.withValues(alpha: 0.72),
    builder: (ctx) {
      final s = S.of(ctx);
      return StatefulBuilder(
        builder: (ctx, setState) => PathSheet(
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Icon(Icons.notifications_none_rounded, size: 40, color: PlColors.accent),
            ),
            const SizedBox(height: 10),
            Text(s.remTitle, style: pathTitleStyle(ctx, size: 22)),
            const SizedBox(height: 6),
            Text(s.remSub, style: pathSubStyle),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final h in _reminderHours) ...[
                  if (h != _reminderHours.first) const SizedBox(width: 8),
                  Expanded(
                    child: SelectTile(
                      label: _hh(h),
                      on: h == hour,
                      onTap: () {
                        pathTap();
                        setState(() => hour = h);
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            PathButton(
              s.remCta(_hh(hour)),
              onPressed: () async {
                pathTap(strong: true);
                await desk.setReminderHour(hour);
                if (ctx.mounted) Navigator.pop(ctx, hour);
              },
            ),
            const SizedBox(height: 10),
            PathButton(
              s.notNow,
              tone: PathButtonTone.ghost,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
    },
  );
}

/// Chip-like selectable tile (reminder time, risk %).
class SelectTile extends StatelessWidget {
  const SelectTile({super.key, required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: PlMotion.micro,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? PlColors.accentDim : PlColors.surface2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: on ? PlColors.accent : PlColors.lineSoft),
          ),
          child: Text(
            label,
            style: pathMono(size: 15, color: on ? PlColors.accent : PlColors.muted),
          ),
        ),
      ),
    );
  }
}

/// Fallback when the first win was earned outside the mission flow.
Future<void> showFirstWinCeremony(BuildContext context) async {
  final desk = context.read<DeskController>();
  if (desk.firstWinCeremonySeen) return;
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (ctx) => Scaffold(
        backgroundColor: PlColors.bg,
        body: SafeArea(child: FirstWinPanel(onDone: () => Navigator.of(ctx).pop())),
      ),
    ),
  );
}

class FirstWinPanel extends StatefulWidget {
  const FirstWinPanel({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<FirstWinPanel> createState() => _FirstWinPanelState();
}

class _FirstWinPanelState extends State<FirstWinPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _ring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<DeskController>().markFirstWinCeremonySeen();
      DeskAudio.instance.play(DeskSfx.win);
      HapticFeedback.heavyImpact();
      if (MediaQuery.disableAnimationsOf(context)) {
        _ring.value = 1;
      } else {
        _ring.forward();
      }
    });
  }

  @override
  void dispose() {
    _ring.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    pathTap(strong: true);
    await context.read<DeskController>().markSoftAuthPromptSeen();
    if (!mounted) return;
    await openSoftAuth(context);
  }

  Future<void> _remind() async {
    pathTap();
    await showReminderSheet(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final reminder = desk.reminderHour;
    final streak = math.max(1, desk.meta.loginStreak);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(child: _StreakRing(progress: _ring, value: streak, label: s.winStreakDay)),
                  const SizedBox(height: 16),
                  Text(s.winTitle, textAlign: TextAlign.center, style: pathTitleStyle(context)),
                  const SizedBox(height: 8),
                  Text(s.winSub, textAlign: TextAlign.center, style: pathSubStyle),
                  const SizedBox(height: 20),
                  _UnlockRow(
                    icon: Icons.lock_open_rounded,
                    iconColor: PlColors.bull,
                    label: 'Daily Desk',
                    badge: s.winOpenBadge,
                  ),
                  const SizedBox(height: 10),
                  _UnlockRow(
                    icon: Icons.menu_book_rounded,
                    iconColor: PlColors.accent,
                    label: s.winJournal,
                    badge: s.winNewBadge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PathButton(s.winSave, onPressed: _save),
          const SizedBox(height: 10),
          PathButton(
            reminder == null ? s.winRemind : s.remSet(_hh(reminder)),
            tone: PathButtonTone.ghost,
            icon: reminder == null ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
            onPressed: _remind,
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: () {
              pathTap();
              widget.onDone();
            },
            child: Text(
              s.winToDesk,
              style: const TextStyle(color: PlColors.accent, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakRing extends StatelessWidget {
  const _StreakRing({required this.progress, required this.value, required this.label});

  final Animation<double> progress;
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 176,
      height: 176,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, child) => CustomPaint(
          painter: _RingPainter(Curves.easeOutCubic.transform(progress.value)),
          child: child,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_fire_department_rounded, size: 30, color: PlColors.warn),
            Text('$value', style: pathMono(size: 52, weight: FontWeight.w700).copyWith(height: 1)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13, color: PlColors.muted)),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width / 2 - 8);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = PlColors.surface3,
    );
    if (t <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * t,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = PlColors.bull,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.t != t;
}

class _UnlockRow extends StatelessWidget {
  const _UnlockRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.badge,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: PlColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PlColors.lineSoft),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15, color: PlColors.text))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PlColors.bullSoft,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badge, style: pathMono(size: 11, color: PlColors.bull)),
          ),
        ],
      ),
    );
  }
}

/// Day-3 (and day-7 retry) Desk Club invitation, shown after a streak — never from Profile.
Future<void> maybeShowCommunityGate(BuildContext context) async {
  final desk = context.read<DeskController>();
  if (!desk.pendingCommunityGate || desk.communityGateAccepted) return;
  await desk.markCommunityGateShown();
  if (!context.mounted) return;
  final s = S.of(context);
  HapticFeedback.mediumImpact();

  final join = await Navigator.of(context).push<bool>(
    MaterialPageRoute<bool>(
      fullscreenDialog: true,
      builder: (_) => const CommunityGateScreen(),
    ),
  );

  if (!context.mounted) return;
  if (join == true) {
    await desk.acceptCommunityGate();
    final ok = await launchUrl(Uri.parse(AppLinks.communityUrl), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.communityOpenError)));
    }
  } else {
    await desk.dismissCommunityGate();
  }
}

class CommunityGateScreen extends StatelessWidget {
  const CommunityGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final streak = math.max(3, desk.meta.loginStreak);
    final trades = desk.history;
    final withStop = trades.where((t) => t.flags.contains(RecapFlag.stopSet)).length;
    final stopPct = trades.isEmpty ? 100 : (withStop * 100 / trades.length).round();

    return Scaffold(
      backgroundColor: PlColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (var d = streak - 2; d <= streak; d++) ...[
                            if (d > streak - 2) const SizedBox(width: 14),
                            _FlameTile(day: d, today: d == streak),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        s.d3Title(streak),
                        textAlign: TextAlign.center,
                        style: pathTitleStyle(context, size: 26),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(child: _Stat(value: '$stopPct%', label: s.d3StopStat, color: PlColors.bull)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _Stat(value: '$streak', label: s.d3StreakStat, color: PlColors.accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      PathCard(
                        accent: true,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: s.d3ClubLead,
                                style: const TextStyle(color: PlColors.accent, fontWeight: FontWeight.w700),
                              ),
                              TextSpan(text: s.d3ClubBody),
                            ],
                          ),
                          style: const TextStyle(fontSize: 15, height: 1.5, color: PathInk.coachText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              PathButton(
                s.d3Join,
                icon: Icons.send_rounded,
                onPressed: () {
                  pathTap(strong: true);
                  Navigator.pop(context, true);
                },
              ),
              const SizedBox(height: 10),
              PathButton(
                s.notNow,
                tone: PathButtonTone.ghost,
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlameTile extends StatelessWidget {
  const _FlameTile({required this.day, required this.today});
  final int day;
  final bool today;

  @override
  Widget build(BuildContext context) {
    final fg = today ? const Color(0xFF1A1000) : PlColors.warn;
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: today ? PlColors.warn : PathInk.warnSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: today ? PlColors.warn : PathInk.warnLine),
        boxShadow: today
            ? [BoxShadow(color: PlColors.warn.withValues(alpha: 0.28), blurRadius: 18)]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 28, color: fg),
          Text('$day', style: pathMono(size: 12, weight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: PlColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: PlColors.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: pathMono(size: 24, weight: FontWeight.w700, color: color)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(fontSize: 12, color: PlColors.muted)),
        ],
      ),
    );
  }
}
