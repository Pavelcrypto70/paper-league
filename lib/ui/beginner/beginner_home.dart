import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/beginner_flow.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:provider/provider.dart';

/// Desk tab for a newcomer: one active mission instead of a full terminal.
class BeginnerHome extends StatelessWidget {
  const BeginnerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final step = desk.beginnerPathStep.clamp(1, 4);
    final done = desk.beginnerMissionsDone;
    final midMission = (step == 3 || step == 4) && desk.position != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.homeGuestCap, style: pathCapStyle),
                  const SizedBox(height: 4),
                  Text(s.homeTitle, style: pathTitleStyle(context)),
                ],
              ),
            ),
            PathChip('$done / 4', tone: PathTone.accent),
          ],
        ),
        const SizedBox(height: 16),
        _Rail(current: step, done: done),
        const SizedBox(height: 16),
        PathCard(
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PathChip(s.missionChip(step, s.pathMinutes(step)), tone: PathTone.accent),
              const SizedBox(height: 10),
              Text(
                s.pathTitle(step),
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: PlColors.text),
              ),
              const SizedBox(height: 6),
              Text(s.pathSub(step), style: pathSubStyle),
              const SizedBox(height: 14),
              PathButton(
                midMission ? s.homeContinue : s.homeStart,
                trailingIcon: Icons.arrow_forward_rounded,
                pulse: done == 0,
                onPressed: () => openBeginnerFlow(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 1; i <= 4; i++)
          if (i != step) _MissionRow(index: i, title: s.pathTitle(i), done: i < step),
        const SizedBox(height: 16),
        PathCard(
          dim: true,
          child: Row(
            children: [
              const Icon(Icons.dashboard_customize_outlined, size: 20, color: PlColors.text),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Desk',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PlColors.text),
                    ),
                    const SizedBox(height: 2),
                    Text(s.homeDailyLocked, style: const TextStyle(fontSize: 13, color: PlColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.lock_outline_rounded, size: 18, color: PlColors.faint),
            ],
          ),
        ),
      ],
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.current, required this.done});

  final int current;
  final int done;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 1; i <= 4; i++) {
      if (i > 1) {
        children.add(
          Expanded(
            child: AnimatedContainer(
              duration: PlMotion.standard,
              height: 2,
              color: i <= done ? PlColors.bull : PlColors.line,
            ),
          ),
        );
      }
      final isDone = i <= done;
      final isCur = i == current && !isDone;
      children.add(
        AnimatedContainer(
          duration: PlMotion.standard,
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? PlColors.bull
                : isCur
                    ? PlColors.accentDim
                    : PlColors.surface,
            border: Border.all(
              width: 2,
              color: isDone
                  ? PlColors.bull
                  : isCur
                      ? PlColors.accent
                      : PlColors.line,
            ),
            boxShadow: isCur
                ? [BoxShadow(color: PlColors.accent.withValues(alpha: 0.12), spreadRadius: 5)]
                : null,
          ),
          child: isDone
              ? const Icon(Icons.check_rounded, size: 18, color: PlColors.onBull)
              : Text(
                  '$i',
                  style: pathMono(
                    size: 14,
                    weight: FontWeight.w700,
                    color: isCur ? PlColors.accent : PlColors.faint,
                  ),
                ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(children: children),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({required this.index, required this.title, required this.done});

  final int index;
  final String title;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 2),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PlColors.lineSoft)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              index.toString().padLeft(2, '0'),
              style: pathMono(size: 12, color: done ? PlColors.bull : PlColors.faint),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                color: done ? PlColors.text : PlColors.muted,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: PlColors.faint,
              ),
            ),
          ),
          Icon(
            done ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            size: 18,
            color: done ? PlColors.bull : PlColors.faint,
          ),
        ],
      ),
    );
  }
}
