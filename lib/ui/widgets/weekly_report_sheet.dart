import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:paper_league/domain/weekly_report.dart';
import 'package:paper_league/l10n/s.dart';
import 'package:paper_league/state/desk_controller.dart';
import 'package:paper_league/theme/tokens.dart';

Future<void> showWeeklyReportSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: PlColors.surface,
    isScrollControlled: true,
    builder: (_) => const WeeklyReportSheet(),
  );
}

class WeeklyReportSheet extends StatelessWidget {
  const WeeklyReportSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final desk = context.watch<DeskController>();
    final s = S.of(context);
    final report = buildWeeklyReport(desk.history);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(PlSpace.lg, PlSpace.md, PlSpace.lg, PlSpace.xl + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: PlSpace.lg),
            Text(s.weeklyReport, style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text(
              report.headline(s.isRu),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(letterSpacing: -0.4),
            ),
            const SizedBox(height: 6),
            Text(s.weeklyReportSub, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            if (report.isEmpty)
              Text(report.bullets(s.isRu).first, style: Theme.of(context).textTheme.bodyLarge)
            else ...[
              Row(
                children: [
                  _Metric(label: s.trades, value: '${report.trades}'),
                  _Metric(label: s.winRate, value: '${report.trades == 0 ? 0 : (report.wins / report.trades * 100).toStringAsFixed(0)}%'),
                  _Metric(label: S.of(context).avgR, value: '${report.avgR >= 0 ? '+' : ''}${report.avgR.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Metric(
                    label: s.widenRate,
                    value: '${report.widenPct.toStringAsFixed(0)}%',
                    color: report.widenPct >= 30 ? PlColors.warn : PlColors.accent,
                  ),
                  _Metric(
                    label: s.leftOnTable,
                    value: '+${report.avgLeftOnTableR.toStringAsFixed(1)}R',
                    color: report.avgLeftOnTableR >= 0.6 ? PlColors.warn : PlColors.bull,
                  ),
                  _Metric(
                    label: s.revengeShort,
                    value: '${report.revengeCount}',
                    color: report.revengeCount > 0 ? PlColors.bear : PlColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _Metric(label: 'Best', value: '${report.bestR >= 0 ? '+' : ''}${report.bestR.toStringAsFixed(2)}R', color: PlColors.bull),
                  _Metric(label: 'Worst', value: '${report.worstR.toStringAsFixed(2)}R', color: PlColors.bear),
                  _Metric(label: 'TP / SL', value: '${report.tpExits}/${report.stopExits}'),
                ],
              ),
              const SizedBox(height: 18),
              Text(s.weeklyPatterns, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              ...report.bullets(s.isRu).map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: PlColors.bgElevated,
                          borderRadius: BorderRadius.circular(PlRadius.md),
                          border: Border.all(color: PlColors.lineSoft),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: Icon(Icons.circle, size: 6, color: PlColors.accent),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(b, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PlColors.text))),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: PlColors.accent,
                foregroundColor: PlColors.onAccent,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Text(s.guideDone),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: PlColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: PlColors.lineSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: color ?? PlColors.text,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
