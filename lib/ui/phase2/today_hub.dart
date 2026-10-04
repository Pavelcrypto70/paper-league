import 'package:flutter/material.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/l10n/s_path.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';
import 'package:paper_league/ui/beginner/path_kit.dart';
import 'package:paper_league/ui/phase2/move1_flow.dart';
import 'package:provider/provider.dart';

const _wdRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
const _wdEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

/// Desk tab after beginner path: bridge once, then Today hub (not raw terminal).
class Phase2Desk extends StatelessWidget {
  const Phase2Desk({super.key});

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    if (desk.showPhase2Bridge) return const _BridgeView();
    return const _TodayHub();
  }
}

class _BridgeView extends StatelessWidget {
  const _BridgeView();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      children: [
        Text(s.bridgeCap, style: pathCapStyle),
        const SizedBox(height: 6),
        Text(s.bridgeTitle, style: pathTitleStyle(context)),
        const SizedBox(height: 8),
        Text(s.bridgeSub, style: pathSubStyle),
        const SizedBox(height: 18),
        PathCard(
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PathChip(s.bridgeChip, tone: PathTone.accent),
              const SizedBox(height: 10),
              Text(
                s.bridgeMoveTitle,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: PlColors.text),
              ),
              const SizedBox(height: 6),
              Text(s.bridgeMoveBody, style: pathSubStyle),
              const SizedBox(height: 14),
              PathButton(
                s.bridgeCta,
                trailingIcon: Icons.arrow_forward_rounded,
                pulse: true,
                onPressed: () async {
                  pathTap(strong: true);
                  await context.read<DeskController>().markPhase2BridgeSeen();
                  if (!context.mounted) return;
                  await openMove1Flow(context);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _LockLine(s.bridgeLockBook),
        _LockLine(s.bridgeLockLeague),
        _LockLine(s.bridgeLockGloss),
      ],
    );
  }
}

class _TodayHub extends StatelessWidget {
  const _TodayHub();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final desk = context.watch<DeskController>();
    final names = s.isRu ? _wdRu : _wdEn;
    final dayNum = desk.habitPathDay;
    final wd = (dayNum - 1) % 7;
    final streak = desk.meta.loginStreak;
    final dayDone = desk.habitViewDayDone;
    final canNext = desk.canAdvanceHabitDay;

    // Task completion for the viewed day (honest checks, not always-on).
    final t1Done = desk.move1Copies >= dayNum || desk.habitDesksDone >= dayNum;
    final t2Done = t1Done; // stop is forced in the copy flow
    final t3Done = desk.habitDesksDone >= dayNum || (dayNum == 1 && desk.move1CopyDone);

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
                  Text(s.todayDayCap(names[wd], dayNum.clamp(1, 28)), style: pathCapStyle),
                  const SizedBox(height: 4),
                  Text(s.todayCap, style: pathTitleStyle(context)),
                ],
              ),
            ),
            PathChip(
              '$streak',
              tone: PathTone.warn,
              icon: Icons.local_fire_department_rounded,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _WeekRow(focus: wd, desksDone: desk.habitDesksDone, viewDay: dayNum),
        const SizedBox(height: 16),
        PathCard(
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.dashboard_customize_outlined, color: PlColors.accent, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    s.todayDeskTitle,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: PlColors.text),
                  ),
                  const Spacer(),
                  PathChip(dayDone ? s.todayDayDone : s.todayDeskMins, tone: dayDone ? PathTone.bull : PathTone.neutral),
                ],
              ),
              const SizedBox(height: 12),
              _Li(s.todayTask1For(dayNum), done: t1Done),
              _Li(s.todayTask2For(dayNum), done: t2Done),
              _Li(s.todayTask3For(dayNum), done: t3Done),
              const SizedBox(height: 14),
              if (canNext) ...[
                PathButton(
                  s.todayNextDay,
                  trailingIcon: Icons.arrow_forward_rounded,
                  pulse: true,
                  onPressed: () async {
                    pathTap(strong: true);
                    await context.read<DeskController>().advanceHabitViewDay();
                  },
                ),
                const SizedBox(height: 8),
                Text(s.todayNextHint, textAlign: TextAlign.center, style: pathFineStyle),
              ] else
                PathButton(
                  desk.move1CopyDone ? s.todayStart : s.bridgeCta,
                  trailingIcon: Icons.arrow_forward_rounded,
                  pulse: !desk.move1CopyDone,
                  onPressed: () async {
                    pathTap(strong: true);
                    if (!desk.move1CopyDone) {
                      await openMove1Flow(context, startAtCopy: desk.move1ReplaySeen);
                      return;
                    }
                    final before = desk.move1Copies;
                    await openMove1Flow(context, startAtCopy: true);
                    if (!context.mounted) return;
                    final after = context.read<DeskController>().move1Copies;
                    if (after > before) {
                      context.read<DeskController>().endTodaySession(countDesk: true);
                    }
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PathCard(
          child: InkWell(
            onTap: () {
              pathTap();
              openMove1Flow(context);
            },
            borderRadius: BorderRadius.circular(PlRadius.lg),
            child: Row(
              children: [
                const Icon(Icons.play_circle_outline_rounded, color: PlColors.accent, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.todayReplay, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(s.todayReplaySub, style: const TextStyle(fontSize: 12, color: PlColors.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: PlColors.faint),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        PathCard(
          dim: desk.meta.loginStreak < 3 && dayNum < 3,
          child: Row(
            children: [
              Icon(
                (desk.meta.loginStreak >= 3 && desk.move1Copies >= 2) || dayNum >= 3
                    ? Icons.send_rounded
                    : Icons.lock_outline_rounded,
                size: 20,
                color: PlColors.faint,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.todayClubLocked, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(s.todayClubLockedSub, style: const TextStyle(fontSize: 12, color: PlColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!desk.move1CopyDone) ...[
          const SizedBox(height: 14),
          Text(s.todayNeedMove, textAlign: TextAlign.center, style: pathFineStyle),
        ],
      ],
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({required this.focus, required this.desksDone, required this.viewDay});
  final int focus;
  final int desksDone;
  final int viewDay;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final names = s.isRu ? _wdRu : _wdEn;
    // Habit week: Пн = day 1 of the current 7-day block.
    final blockStart = ((viewDay - 1) ~/ 7) * 7;
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _done(i, blockStart) ? PlColors.bull : Colors.transparent,
                    border: Border.all(
                      color: i == focus
                          ? PlColors.accent
                          : (_done(i, blockStart) ? PlColors.bull : PlColors.line),
                      width: i == focus ? 2 : 1.5,
                    ),
                    boxShadow: i == focus
                        ? [BoxShadow(color: PlColors.accent.withValues(alpha: 0.14), spreadRadius: 4)]
                        : null,
                  ),
                  child: _done(i, blockStart)
                      ? const Icon(Icons.check_rounded, size: 16, color: PlColors.onBull)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  names[i],
                  style: pathMono(
                    size: 11,
                    color: i == focus ? PlColors.accent : PlColors.faint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  bool _done(int i, int blockStart) {
    final day = blockStart + i + 1;
    return desksDone >= day;
  }
}

class _Li extends StatelessWidget {
  const _Li(this.text, {required this.done});
  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_rounded : Icons.circle_outlined,
            size: 18,
            color: done ? PlColors.accent : PlColors.faint,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: done ? PathInk.body : PlColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LockLine extends StatelessWidget {
  const _LockLine(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 18, color: PlColors.faint),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: PlColors.muted))),
        ],
      ),
    );
  }
}
