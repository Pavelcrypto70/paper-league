import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paper_league/config/app_links.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/screens/auth_gate_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Mission rail shown on Desk while beginner path is incomplete.
class BeginnerMissionRail extends StatelessWidget {
  const BeginnerMissionRail({super.key});

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    if (!desk.beginnerPathActive) return const SizedBox.shrink();

    final step = desk.beginnerPathStep.clamp(1, 4);
    final done = desk.beginnerMissionsDone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(PlSpace.lg, 8, PlSpace.lg, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PlColors.accentDim,
          borderRadius: BorderRadius.circular(PlRadius.md),
          border: Border.all(color: PlColors.accent.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  s.missionRailTitle,
                  style: const TextStyle(
                    color: PlColors.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Text(
                  '$done/4',
                  style: const TextStyle(
                    color: PlColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: done / 4,
                minHeight: 4,
                backgroundColor: PlColors.surface2,
                color: PlColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 1; i <= 4; i++) ...[
              if (i > 1) const SizedBox(height: 6),
              _MissionRow(
                index: i,
                title: _missionTitle(s, i),
                body: _missionBody(s, i),
                state: i < step
                    ? _MissionState.done
                    : i == step
                        ? _MissionState.active
                        : _MissionState.locked,
                onStart: i == step ? () => _startMission(context, desk, i) : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _missionTitle(S s, int i) => switch (i) {
        1 => s.mission1Title,
        2 => s.mission2Title,
        3 => s.mission3Title,
        _ => s.mission4Title,
      };

  String _missionBody(S s, int i) => switch (i) {
        1 => s.mission1Body,
        2 => s.mission2Body,
        3 => s.mission3Body,
        _ => s.mission4Body,
      };

  Future<void> _startMission(BuildContext context, DeskController desk, int step) async {
    DeskAudio.instance.play(DeskSfx.tap);
    HapticFeedback.selectionClick();
    switch (step) {
      case 1:
        await showCandleMissionSheet(context);
      case 2:
        await desk.ensureTutorialTrade();
      case 3:
        desk.placeTutorialStop();
      case 4:
        desk.closePosition();
    }
  }
}

enum _MissionState { locked, active, done }

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    required this.index,
    required this.title,
    required this.body,
    required this.state,
    this.onStart,
  });

  final int index;
  final String title;
  final String body;
  final _MissionState state;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final active = state == _MissionState.active;
    final done = state == _MissionState.done;
    final locked = state == _MissionState.locked;
    return AnimatedOpacity(
      duration: PlMotion.micro,
      opacity: locked ? 0.45 : 1,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? PlColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(PlRadius.sm),
          border: Border.all(
            color: active
                ? PlColors.accent.withValues(alpha: 0.55)
                : done
                    ? PlColors.bull.withValues(alpha: 0.35)
                    : PlColors.lineSoft,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done
                    ? PlColors.bullSoft
                    : active
                        ? PlColors.accentSoft
                        : PlColors.surface2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: done
                  ? const Icon(Icons.check_rounded, size: 16, color: PlColors.bull)
                  : locked
                      ? const Icon(Icons.lock_outline, size: 14, color: PlColors.faint)
                      : Text(
                          '$index',
                          style: const TextStyle(
                            color: PlColors.accent,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: done ? PlColors.bull : PlColors.text,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PlColors.muted,
                          height: 1.3,
                        ),
                  ),
                  if (active && onStart != null) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: PlColors.accent,
                          foregroundColor: PlColors.onAccent,
                        ),
                        onPressed: onStart,
                        child: Text(
                          index == 1
                              ? s.missionStart
                              : index == 2
                                  ? s.missionBuyLong
                                  : index == 3
                                      ? s.gestureStopCta
                                      : s.missionCloseJournal,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCandleMissionSheet(BuildContext context) async {
  final desk = context.read<DeskController>();
  final s = S.of(context);
  var q = 0;
  final answers = <int?>[null, null];
  const correct = [0, 1]; // Q1: Open = left, Q2: Close decides color

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: PlColors.surface,
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final questions = [
            (
              s.mission1Q1,
              [s.mission1Q1A, s.mission1Q1B],
            ),
            (
              s.mission1Q2,
              [s.mission1Q2A, s.mission1Q2B],
            ),
          ];
          final page = questions[q];
          final picked = answers[q];
          final bottom = MediaQuery.viewInsetsOf(ctx).bottom;
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PlColors.line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(s.mission1Title, style: Theme.of(ctx).textTheme.headlineSmall),
                const SizedBox(height: 6),
                Text(s.mission1Explain, style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 14),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: PlColors.bg,
                    borderRadius: BorderRadius.circular(PlRadius.md),
                    border: Border.all(color: PlColors.lineSoft),
                  ),
                  child: CustomPaint(painter: _OhlcDemoPainter()),
                ),
                const SizedBox(height: 14),
                Text(
                  '${q + 1}/2 · ${page.$1}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < page.$2.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: picked == i ? PlColors.accent : PlColors.text,
                      side: BorderSide(
                        color: picked == i ? PlColors.accent : PlColors.line,
                      ),
                      backgroundColor:
                          picked == i ? PlColors.accentSoft : Colors.transparent,
                    ),
                    onPressed: () {
                      DeskAudio.instance.play(DeskSfx.tap);
                      setState(() => answers[q] = i);
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(page.$2[i]),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                FilledButton(
                  onPressed: picked == null
                      ? null
                      : () async {
                          DeskAudio.instance.play(DeskSfx.tap);
                          HapticFeedback.selectionClick();
                          if (picked != correct[q]) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(s.mission1Wrong)),
                            );
                            return;
                          }
                          if (q == 0) {
                            setState(() => q = 1);
                            return;
                          }
                          await desk.completeCandleMission();
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                  child: Text(q == 0 ? s.guideNext : s.mission1Done),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _OhlcDemoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final openY = size.height * 0.62;
    final closeY = size.height * 0.32;
    final highY = size.height * 0.18;
    final lowY = size.height * 0.82;
    final wick = Paint()
      ..color = PlColors.wick
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cx, highY), Offset(cx, lowY), wick);
    final body = RRect.fromRectAndRadius(
      Rect.fromLTRB(cx - 18, closeY, cx + 18, openY),
      const Radius.circular(2),
    );
    canvas.drawRRect(body, Paint()..color = PlColors.bull);
    final label = Paint()..color = PlColors.muted;
    // tiny ticks for O/H/L/C labels via short lines
    canvas.drawCircle(Offset(cx + 28, openY), 2.5, label);
    canvas.drawCircle(Offset(cx + 28, closeY), 2.5, Paint()..color = PlColors.bull);
    canvas.drawCircle(Offset(cx - 28, highY), 2.5, label);
    canvas.drawCircle(Offset(cx - 28, lowY), 2.5, label);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<void> showFirstWinCeremony(BuildContext context) async {
  final desk = context.read<DeskController>();
  if (desk.firstWinCeremonySeen) return;
  final s = S.of(context);
  DeskAudio.instance.play(DeskSfx.win);
  HapticFeedback.heavyImpact();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: PlColors.surface,
    isDismissible: false,
    enableDrag: false,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: PlColors.line,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(s.firstWinTitle, style: Theme.of(ctx).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(s.firstWinBody, style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PlColors.accentDim,
                borderRadius: BorderRadius.circular(PlRadius.md),
                border: Border.all(color: PlColors.accent.withValues(alpha: 0.35)),
              ),
              child: Text(
                '${s.streakLabel} 1 · ${s.dailyDeskUnlocked}',
                style: const TextStyle(
                  color: PlColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                DeskAudio.instance.play(DeskSfx.tap);
                await desk.markSoftAuthPromptSeen();
                await desk.markFirstWinCeremonySeen();
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!context.mounted) return;
                await _openSoftAuth(context);
              },
              child: Text(s.saveProgressCta),
            ),
            TextButton(
              onPressed: () async {
                DeskAudio.instance.play(DeskSfx.tap);
                await desk.markFirstWinCeremonySeen();
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(s.remindLater),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _openSoftAuth(BuildContext context) async {
  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (ctx) => AuthGateScreen(
        onReady: () {
          if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
        },
      ),
    ),
  );
}

Future<void> maybeShowCommunityGate(BuildContext context) async {
  final desk = context.read<DeskController>();
  if (!desk.pendingCommunityGate || desk.communityGateAccepted) return;
  await desk.markCommunityGateShown();
  if (!context.mounted) return;
  final s = S.of(context);
  DeskAudio.instance.play(DeskSfx.tap);
  HapticFeedback.mediumImpact();

  final join = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: PlColors.surface,
        title: Text(s.communityGateTitle),
        content: Text(s.communityGateBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.communityGateLater),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.joinCommunity),
          ),
        ],
      );
    },
  );

  if (!context.mounted) return;
  if (join == true) {
    await desk.acceptCommunityGate();
    final uri = Uri.parse(AppLinks.communityUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.communityOpenError)),
      );
    }
  } else {
    await desk.dismissCommunityGate();
  }
}
