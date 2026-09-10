import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/services/desk_audio.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';

class DailyDeskStrip extends StatelessWidget {
  const DailyDeskStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final d = desk.daily;

    return Padding(
      padding: const EdgeInsets.fromLTRB(PlSpace.lg, 8, PlSpace.lg, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PlRadius.md),
          gradient: LinearGradient(
            colors: [
              d.complete ? PlColors.bullSoft : PlColors.accentDim,
              PlColors.surface,
            ],
          ),
          border: Border.all(
            color: (d.complete ? PlColors.bull : PlColors.accent).withValues(alpha: 0.35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  s.dailyDesk,
                  style: TextStyle(
                    color: d.complete ? PlColors.bull : PlColors.accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                Text(
              '${s.streakLabel} ${desk.meta.loginStreak}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    color: PlColors.muted,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${d.done}/${d.total}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              desk.seasonPressureFor(s.isRu),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: PlColors.faint),
            ),
            const SizedBox(height: 4),
            Text(
              '${s.shields} ${desk.seasonProgress.streakShields} · SP ${desk.seasonProgress.seasonXp}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: PlColors.muted),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: d.progress,
                minHeight: 3,
                backgroundColor: PlColors.surface2,
                color: d.complete ? PlColors.bull : PlColors.accent,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Chip(ok: d.plannedTrade, label: s.dailyPlan),
                _Chip(ok: d.cleanStop, label: s.dailyStop),
                _Chip(ok: d.drillDone, label: s.dailyDrill),
                _Chip(ok: d.sharedCard, label: s.dailyShare),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.ok, required this.label});
  final bool ok;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 4),
        child: AnimatedContainer(
          duration: PlMotion.micro,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: ok ? PlColors.accentSoft : PlColors.bgElevated,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ok ? PlColors.accent.withValues(alpha: 0.4) : PlColors.lineSoft),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                ok ? Icons.check_rounded : Icons.circle_outlined,
                size: 11,
                color: ok ? PlColors.accent : PlColors.faint,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: ok ? PlColors.accent : PlColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showPreTradeCheck(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: PlColors.surface,
    isScrollControlled: true,
    builder: (_) => const _PreTradeSheet(),
  );
  return result == true;
}

class _PreTradeSheet extends StatefulWidget {
  const _PreTradeSheet();

  @override
  State<_PreTradeSheet> createState() => _PreTradeSheetState();
}

class _PreTradeSheetState extends State<_PreTradeSheet> {
  bool thesis = false;
  bool stop = false;
  bool size = false;
  bool calm = false;

  bool get ready => thesis && stop && size && calm;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(PlSpace.lg, PlSpace.md, PlSpace.lg, PlSpace.xl + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: PlColors.line, borderRadius: BorderRadius.circular(99)),
            ),
          ),
          const SizedBox(height: PlSpace.lg),
          Text(s.preTrade, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(s.preTradeSub, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: PlSpace.lg),
          _Check(label: s.preThesis, value: thesis, onChanged: (v) => setState(() => thesis = v)),
          _Check(label: s.preStop, value: stop, onChanged: (v) => setState(() => stop = v)),
          _Check(label: s.preSize, value: size, onChanged: (v) => setState(() => size = v)),
          _Check(label: s.preCalm, value: calm, onChanged: (v) => setState(() => calm = v)),
          const SizedBox(height: PlSpace.lg),
          FilledButton(
            onPressed: ready
                ? () {
                    DeskAudio.instance.play(DeskSfx.tap);
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context, true);
                  }
                : null,
            child: Text(s.preTradeGo),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.back),
          ),
        ],
      ),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: value ? PlColors.accentSoft : PlColors.bgElevated,
        borderRadius: BorderRadius.circular(PlRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(PlRadius.md),
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(!value);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PlRadius.md),
              border: Border.all(color: value ? PlColors.accent.withValues(alpha: 0.45) : PlColors.lineSoft),
            ),
            child: Row(
              children: [
                Icon(
                  value ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: value ? PlColors.accent : PlColors.faint,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
